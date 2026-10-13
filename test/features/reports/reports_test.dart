import 'package:agentkhata/core/ledger/transaction_draft.dart';
import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/reports/csv_export.dart';
import 'package:agentkhata/features/reports/report_queries.dart';
import 'package:agentkhata/features/transactions/history_filter.dart';
import 'package:agentkhata/features/transactions/history_queries.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

void main() {
  late LedgerFixture f;
  late ReportQueries reports;

  setUp(() async {
    f = await LedgerFixture.create();
    reports = ReportQueries(f.db);
  });
  tearDown(() => f.dispose());

  DateTime at(int day, [int hour = 10]) => DateTime.utc(2026, 10, day, hour);

  group('summary', () {
    test('totals, per type and a net series by business day', () async {
      await f.txns.post(f.cashOutDraft(1000, at: at(10))); // commission 40
      await f.txns.post(f.cashOutDraft(500, at: at(10, 11))); // 20
      await f.txns.post(f.cashInDraft(300, at: at(11)));
      await f.txns.post(
        TransactionDraft(
          type: TransactionType.flexiload,
          occurredAt: at(11),
          amount: const Money.taka(100),
          fromAccountId: f.gpLoad,
          toAccountId: f.cash,
          commission: const Money.taka(3),
        ),
      );
      await f.txns.post(
        TransactionDraft(
          type: TransactionType.expense,
          occurredAt: at(12),
          amount: const Money.taka(50),
          fromAccountId: f.cash,
          toAccountId: f.rent,
        ),
      );
      final voided = await f.txns.post(f.cashOutDraft(9999, at: at(12)));
      await f.txns.voidTransaction(voided, reason: 'x', userId: 'owner');

      final s = await reports.summary(at(1), at(30));
      expect(s.count, 5);
      expect(s.cashOutVolume, const Money.taka(1500));
      expect(s.cashInVolume, const Money.taka(300));
      expect(s.commission.paisa, 6000);
      expect(s.flexiloadMargin, const Money.taka(3));
      expect(s.expenses, const Money.taka(50));
      expect(s.netProfit.paisa, 6000 + 300 - 5000);
      expect(s.perType[TransactionType.cashOut]!.count, 2);

      expect(s.daily.map((d) => d.businessDate), [
        '2026-10-10',
        '2026-10-11',
        '2026-10-12',
      ]);
      expect(s.daily[0].net.paisa, 6000);
      expect(s.daily[1].net.paisa, 300);
      expect(s.daily[2].net.paisa, -5000);
    });

    test('rollover hour moves night sales to the previous day', () async {
      // 01:00 Dhaka on the 11th = 19:00 UTC on the 10th.
      await f.txns.post(
        f.cashOutDraft(100, at: DateTime.utc(2026, 10, 10, 19)),
      );
      final r0 = await reports.summary(at(1), at(30));
      expect(r0.daily.single.businessDate, '2026-10-11');
      final r4 = await reports.summary(at(1), at(30), rolloverHour: 4);
      expect(r4.daily.single.businessDate, '2026-10-10');
    });

    test('adjustments are not business volume', () async {
      await f.txns.post(
        TransactionDraft(
          type: TransactionType.adjustment,
          occurredAt: at(10),
          amount: const Money.taka(5),
          toAccountId: f.cash,
          note: 'x',
        ),
      );
      final s = await reports.summary(at(1), at(30));
      expect(s.count, 0);
    });
  });

  group('commission expected vs received', () {
    test('per provider, with pending amount', () async {
      await f.txns.post(f.cashOutDraft(1000, at: at(10))); // bkash 40
      await f.txns.post(
        f.cashOutDraft(2000, at: at(11), wallet: f.nagad),
      ); // 80
      await f.txns.post(
        TransactionDraft(
          type: TransactionType.commissionReceived,
          occurredAt: at(12),
          amount: const Money.taka(25),
          toAccountId: f.bkash,
        ),
      );

      final c = await reports.commissionComparison();
      final bkash = c.firstWhere((x) => x.provider == 'bkash');
      final nagad = c.firstWhere((x) => x.provider == 'nagad');
      expect(bkash.expected.paisa, 4000);
      expect(bkash.received, const Money.taka(25));
      expect(bkash.pending.paisa, 4000 - 2500);
      expect(nagad.received, Money.zero);
      expect(nagad.pending.paisa, 8000);

      // Receiving raises the wallet float.
      expect(await f.accounts.balanceOf(f.bkash), const Money.taka(51025));
    });

    test('honours the date range and ignores voids', () async {
      await f.txns.post(f.cashOutDraft(1000, at: at(10)));
      final late = await f.txns.post(f.cashOutDraft(1000, at: at(20)));
      await f.txns.voidTransaction(late, reason: 'x', userId: 'owner');
      final c = await reports.commissionComparison(start: at(1), end: at(15));
      expect(c.single.expected.paisa, 4000);
    });
  });

  test('variance history lists closed days oldest first', () async {
    await f.db.customStatement(
      "INSERT INTO day_close (id, business_date, status) VALUES ('d1', '2026-10-10', 'closed')",
    );
    await f.db.customStatement(
      "INSERT INTO day_close (id, business_date, status) VALUES ('d2', '2026-10-11', 'closed')",
    );
    await f.db.customStatement(
      "INSERT INTO day_close (id, business_date, status) VALUES ('d3', '2026-10-12', 'reopened')",
    );
    for (final (dc, acct, v) in [
      ('d1', f.cash, -500),
      ('d1', f.bkash, 200),
      ('d2', f.cash, 0),
      ('d3', f.cash, 999),
    ]) {
      await f.db.customStatement(
        'INSERT INTO day_close_line (day_close_id, account_id, expected_paisa, '
        'actual_paisa, variance_paisa) VALUES (?, ?, 0, 0, ?)',
        [dc, acct, v],
      );
    }
    final h = await reports.varianceHistory();
    expect(h.map((p) => p.businessDate), ['2026-10-10', '2026-10-11']);
    expect(h.map((p) => p.variance.paisa), [-300, 0]);
  });

  group('variance patterns', () {
    // Mon 19 Oct, Tue 20, Mon 26: per-account lines written directly.
    Future<void> closedDay(
      String id,
      String date,
      Map<String, int> variance, {
      String status = 'closed',
    }) async {
      await f.db.customStatement(
        'INSERT INTO day_close (id, business_date, status) VALUES (?, ?, ?)',
        [id, date, status],
      );
      for (final e in variance.entries) {
        await f.db.customStatement(
          'INSERT INTO day_close_line (day_close_id, account_id, expected_paisa, '
          'actual_paisa, variance_paisa) VALUES (?, ?, 0, 0, ?)',
          [id, e.key, e.value],
        );
      }
    }

    setUp(() async {
      await closedDay('d1', '2026-10-19', {f.cash: -50000, f.bkash: 10000});
      await closedDay('d2', '2026-10-20', {f.cash: 0, f.bkash: 5000});
      await closedDay('d3', '2026-10-26', {f.cash: -20000, f.bkash: 0});
      await closedDay('d4', '2026-10-27', {f.cash: -99900}, status: 'reopened');
    });

    test('history can be filtered to one account', () async {
      final cash = await reports.varianceHistory(accountId: f.cash);
      expect(cash.map((p) => p.variance.paisa), [-50000, 0, -20000]);
      final all = await reports.varianceHistory();
      expect(all.map((p) => p.variance.paisa), [-40000, 5000, -20000]);
    });

    test(
      'per account totals, most short first, reopened days excluded',
      () async {
        final by = await reports.varianceByAccount();
        expect(by.first.label, 'Cash');
        expect(by.first.shortage.paisa, -70000);
        expect(by.first.excess, Money.zero);
        expect(by.first.daysWithDifference, 2);
        expect(by.first.closedDays, 3);
        final bkash = by.firstWhere((a) => a.label == 'bKash');
        expect(bkash.total.paisa, 15000);
        expect(bkash.excess.paisa, 15000);
        expect(bkash.shortage, Money.zero);
      },
    );

    test('the window limits how many recent days count', () async {
      final by = await reports.varianceByAccount(limit: 1);
      final cash = by.firstWhere((a) => a.label == 'Cash');
      expect(cash.closedDays, 1); // only 26 Oct
      expect(cash.shortage.paisa, -20000);
    });

    test('by weekday groups business dates', () async {
      final w = await reports.varianceByWeekday();
      expect(w, hasLength(7));
      final mon = w[0];
      expect(mon.weekday, 1);
      expect(mon.closedDays, 2); // 19th and 26th
      expect(mon.shortDays, 2);
      expect(mon.shortage.paisa, -60000); // -40000 and -20000
      expect(mon.averageNet.paisa, -30000);
      final tue = w[1];
      expect(tue.closedDays, 1);
      expect(tue.shortDays, 0);
      expect(tue.net.paisa, 5000);
      expect(w[4].closedDays, 0);
      expect(w[4].averageNet, Money.zero);
    });
  });

  group('csv', () {
    test('rows, quoting, BOM and Dhaka time', () async {
      await f.txns.post(
        TransactionDraft(
          type: TransactionType.cashOut,
          occurredAt: DateTime.utc(2026, 10, 20, 18, 30), // 00:30 on the 21st
          amount: const Money.paisa(150050),
          fromAccountId: f.cash,
          toAccountId: f.bkash,
          commission: const Money.paisa(600),
          customerNumber: '01712345678',
          reference: 'TRX1',
          note: 'rent, "advance"',
        ),
      );
      final items = await HistoryQueries(f.db).page(const HistoryFilter());
      final csv = TransactionCsv.build(items);

      expect(csv.startsWith('﻿'), isTrue);
      final lines = csv.substring(1).trim().split('\r\n');
      expect(lines.first, TransactionCsv.header.join(','));
      expect(
        lines[1],
        '2026-10-21,00:30,cash_out,bKash,,01712345678,1500.50,0,6,TRX1,'
        '"rent, ""advance""",active,',
      );
    });

    test('cells that look like formulas are neutralized', () async {
      await f.txns.post(
        TransactionDraft(
          type: TransactionType.cashOut,
          occurredAt: at(10),
          amount: const Money.taka(10),
          fromAccountId: f.cash,
          toAccountId: f.bkash,
          note: '=HYPERLINK("http://x")',
        ),
      );
      final items = await HistoryQueries(f.db).page(const HistoryFilter());
      final csv = TransactionCsv.build(items);
      expect(csv, contains("\"'=HYPERLINK(\"\"http://x\"\")\""));
    });
  });

  test('paginate splits evenly and keeps the remainder', () {
    expect(paginate([1, 2, 3, 4, 5], 2), [
      [1, 2],
      [3, 4],
      [5],
    ]);
    expect(paginate(<int>[], 3), isEmpty);
    expect(() => paginate([1], 0), throwsArgumentError);
  });
}
