import 'package:agentkhata/core/i18n/digit_formatter.dart';
import 'package:agentkhata/core/ledger/transaction_draft.dart';
import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/core/money/money_formatter.dart';
import 'package:agentkhata/features/closeday/day_close_service.dart';
import 'package:agentkhata/features/insights/insights_queries.dart';
import 'package:agentkhata/features/sheet/daily_sheet_model.dart';
import 'package:agentkhata/features/sheet/daily_sheet_queries.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

SheetLabels _labels() => SheetLabels(
  title: 'Daily sheet',
  status: 'Closed',
  time: 'Time',
  particulars: 'Particulars',
  moneyIn: 'In',
  moneyOut: 'Out',
  balance: 'Balance',
  opening: 'Opening',
  closing: 'Closing',
  walletsHeading: 'Account',
  expected: 'Expected',
  actual: 'Actual',
  difference: 'Difference',
  summaryHeading: 'Summary',
  entries: 'Entries',
  cashInTotal: 'Cash in',
  cashOutTotal: 'Cash out',
  commission: 'Commission',
  margin: 'Margin',
  expenses: 'Expenses',
  netProfit: 'Net profit',
  preparedBy: 'Prepared by',
  checkedBy: 'Checked by',
  voided: 'void',
  typeLabel: (t) => t.dbName,
  pageOf: (n, total) => '$n/$total',
  numberText: (n) => '$n',
);

void main() {
  late LedgerFixture f;
  setUp(() async => f = await LedgerFixture.create());
  tearDown(() => f.dispose());

  DateTime at(int hour, {int day = 20}) =>
      DateTime.utc(2026, 10, day, hour, 30);

  const money = MoneyFormatter(
    digits: DigitFormatter(style: DigitStyle.latin, bangladeshiGrouping: false),
    showSymbol: false,
  );

  group('cash sheet query', () {
    test('opening, running balance, counterparty and voids', () async {
      // Before the day: cash 10,000 -> 9,000.
      await f.txns.post(
        f.cashOutDraft(1000, at: DateTime.utc(2026, 10, 19, 10)),
      );
      await f.txns.post(f.cashOutDraft(2000, at: at(4))); // 7,000
      final voided = await f.txns.post(f.cashOutDraft(500, at: at(5)));
      await f.txns.voidTransaction(voided, reason: 'x', userId: 'owner');
      await f.txns.post(f.cashInDraft(300, at: at(6))); // 7,300
      await f.txns.post(
        TransactionDraft(
          type: TransactionType.expense,
          occurredAt: at(7),
          amount: const Money.taka(50),
          fromAccountId: f.cash,
          toAccountId: f.rent,
          note: 'tea',
        ),
      ); // 7,250
      // A different day must not leak in.
      await f.txns.post(f.cashOutDraft(9, at: DateTime.utc(2026, 10, 21, 10)));

      final data = (await DailySheetQueries(f.db)
          .cash(DateTime.utc(2026, 10, 20), DateTime.utc(2026, 10, 21)))!;
      expect(data.opening, const Money.taka(9000));
      expect(data.closing, const Money.taka(7250));
      expect(data.lines, hasLength(4));
      expect(data.lines.map((l) => l.balance.wholeTaka), [
        7000,
        7000,
        7300,
        7250,
      ]);
      expect(data.lines[0].counterparty, 'bKash');
      expect(data.lines[1].isVoid, isTrue);
      expect(data.lines[3].counterparty, 'Rent');
      expect(data.lines[3].note, 'tea');
    });

    test('no cash account means no ledger', () async {
      await f.db.customStatement(
        "UPDATE account SET is_active = 0 WHERE kind = 'cash'",
      );
      expect(
        await DailySheetQueries(f.db)
            .cash(DateTime.utc(2026, 10, 20), DateTime.utc(2026, 10, 21)),
        isNull,
      );
    });
  });

  group('sheet pagination', () {
    DailySummaryData summary({int accounts = 3}) => DailySummaryData(
      businessDate: '2026-10-20',
      status: 'closed',
      count: 12,
      cashInVolume: const Money.taka(5000),
      cashOutVolume: const Money.taka(7000),
      commission: const Money.taka(120),
      flexiloadMargin: const Money.taka(30),
      expenses: const Money.taka(50),
      totalVariance: const Money.taka(-10),
      accounts: [
        for (var i = 0; i < accounts; i++)
          SummaryAccountLine(
            label: 'Acc$i',
            opening: const Money.taka(100),
            moneyIn: const Money.taka(10),
            moneyOut: const Money.taka(5),
            expected: const Money.taka(105),
            actual: const Money.taka(105),
          ),
      ],
    );

    CashSheetData cashWith(int n) => CashSheetData(
      cashAccountLabel: 'Cash',
      opening: const Money.taka(1000),
      closing: Money.taka(1000 + n),
      lines: [
        for (var i = 0; i < n; i++)
          CashSheetLine(
            occurredAt: at(4),
            type: TransactionType.cashIn,
            delta: const Money.taka(1),
            balance: Money.taka(1001 + i),
            isVoid: false,
            counterparty: 'bKash',
          ),
      ],
    );

    List<SheetPage> build(int lines, {bool profit = true, int accounts = 3}) =>
        const DailySheetBuilder().build(
          summary: summary(accounts: accounts),
          cash: cashWith(lines),
          money: money,
          timeText: (d) => '${d.hour}:${d.minute}',
          dateText: '20 Oct 2026',
          shopName: 'Rahim Store',
          labels: _labels(),
          showProfit: profit,
        );

    test('a short day fits on one page with the final section', () {
      final pages = build(5);
      expect(pages, hasLength(1));
      expect(pages.single.hasFinalSection, isTrue);
      expect(pages.single.ledgerRows, hasLength(5 + 2)); // opening + closing
      expect(pages.single.title, 'Rahim Store · 20 Oct 2026');
      expect(pages.single.footer, '1/1');
      expect(pages.single.signatures, ['Prepared by', 'Checked by']);
    });

    test('rows overflow onto more pages; only the last has the summary', () {
      final pages = build(80);
      expect(pages.length, greaterThan(2));
      expect(pages.map((p) => p.hasFinalSection), [
        ...List.filled(pages.length - 1, false),
        true,
      ]);
      final allRows = pages.expand((p) => p.ledgerRows).toList();
      expect(allRows, hasLength(80 + 2));
      expect(pages.last.footer, '${pages.length}/${pages.length}');
    });

    test('a full last ledger page pushes the summary to its own page', () {
      // A page holds 27 rows; 25 lines + opening + closing = 27 exactly.
      final pages = build(25);
      expect(pages, hasLength(2));
      expect(pages.first.hasFinalSection, isFalse);
      expect(pages.last.ledgerRows, isEmpty);
      expect(pages.last.hasFinalSection, isTrue);
    });

    test('closing row totals ignore voided lines; profit can be hidden', () {
      final cash = CashSheetData(
        cashAccountLabel: 'Cash',
        opening: const Money.taka(100),
        closing: const Money.taka(150),
        lines: [
          CashSheetLine(
            occurredAt: at(4),
            type: TransactionType.cashIn,
            delta: const Money.taka(80),
            balance: const Money.taka(180),
            isVoid: false,
          ),
          CashSheetLine(
            occurredAt: at(5),
            type: TransactionType.cashOut,
            delta: const Money.taka(-30),
            balance: const Money.taka(150),
            isVoid: false,
          ),
          CashSheetLine(
            occurredAt: at(6),
            type: TransactionType.cashOut,
            delta: const Money.taka(-999),
            balance: const Money.taka(150),
            isVoid: true,
          ),
        ],
      );
      final pages = const DailySheetBuilder().build(
        summary: summary(),
        cash: cash,
        money: money,
        timeText: (d) => 'T',
        dateText: 'D',
        shopName: '',
        labels: _labels(),
        showProfit: false,
      );
      final rows = pages.single.ledgerRows;
      expect(rows.last.cells, ['', 'Closing', '80', '30', '150']);
      expect(rows[3].isVoid, isTrue);
      expect(rows[3].cells[4], ''); // no balance on a voided line
      expect(pages.single.title, 'Daily sheet · D');

      final labelsShown = pages.single.summary.map((s) => s.$1).toList();
      expect(labelsShown, isNot(contains('Commission')));
      expect(labelsShown, isNot(contains('Net profit')));
      expect(labelsShown, contains('Difference'));
    });

    test('no cash account still produces a sheet', () {
      final pages = const DailySheetBuilder().build(
        summary: summary(),
        cash: null,
        money: money,
        timeText: (d) => 'T',
        dateText: 'D',
        shopName: '',
        labels: _labels(),
        showProfit: true,
      );
      expect(pages, hasLength(1));
      expect(pages.single.ledgerRows, isEmpty);
      expect(pages.single.walletRows, hasLength(3));
    });
  });

  group('insights', () {
    DateTime dhaka(int day, int hour) =>
        // Dhaka is UTC+6: hour h Dhaka = (h - 6) UTC.
        DateTime.utc(2026, 10, day, hour - 6, 15);

    Future<Insights> compute({int rollover = 0}) => InsightsQueries(f.db)
        .compute(
          DateTime.utc(2026, 10, 1),
          DateTime.utc(2026, 11, 1),
          rolloverHour: rollover,
        );

    test('hourly counts and profit use Dhaka clock hours', () async {
      // 2026-10-19 is a Monday, 2026-10-20 a Tuesday.
      await f.txns.post(
        f.cashOutDraft(1000, at: dhaka(19, 18)),
      ); // 18h, 40 comm
      await f.txns.post(f.cashOutDraft(2000, at: dhaka(19, 18))); // 18h, 80
      await f.txns.post(f.cashOutDraft(500, at: dhaka(20, 11))); // 11h, 20
      await f.txns.post(f.cashInDraft(300, at: dhaka(20, 11))); // 11h, 0

      final ins = await compute();
      expect(ins.count, 4);
      expect(ins.hours, hasLength(24));
      expect(ins.hours[18].count, 2);
      expect(ins.hours[18].profit.paisa, 12000);
      expect(ins.hours[11].count, 2);
      expect(ins.busiestHour!.hour, anyOf(11, 18));
      expect(ins.mostProfitableHour!.hour, 18);
      expect(ins.hours[3].count, 0);
    });

    test('average size overall and per type', () async {
      await f.txns.post(f.cashOutDraft(1000, at: dhaka(19, 10)));
      await f.txns.post(f.cashOutDraft(3000, at: dhaka(19, 11)));
      await f.txns.post(f.cashInDraft(200, at: dhaka(19, 12)));
      // Not a sale: an expense must be ignored.
      await f.txns.post(
        TransactionDraft(
          type: TransactionType.expense,
          occurredAt: dhaka(19, 13),
          amount: const Money.taka(9999),
          fromAccountId: f.cash,
          toAccountId: f.rent,
        ),
      );
      final ins = await compute();
      expect(ins.count, 3);
      expect(ins.averageSize, const Money.taka(1400));
      final out = ins.byType.firstWhere(
        (t) => t.type == TransactionType.cashOut,
      );
      expect(out.count, 2);
      expect(out.average, const Money.taka(2000));
    });

    test('weekday profit per active day', () async {
      // Two Mondays (19th, 26th), one Tuesday (20th).
      await f.txns.post(f.cashOutDraft(1000, at: dhaka(19, 10))); // Mon 40
      await f.txns.post(f.cashOutDraft(1000, at: dhaka(26, 10))); // Mon 40
      await f.txns.post(f.cashOutDraft(5000, at: dhaka(20, 10))); // Tue 200
      final ins = await compute();
      final mon = ins.weekdays[0];
      final tue = ins.weekdays[1];
      expect(mon.weekday, 1);
      expect(mon.activeDays, 2);
      expect(mon.profit.paisa, 8000);
      expect(mon.profitPerDay.paisa, 4000);
      expect(tue.profitPerDay.paisa, 20000);
      expect(ins.bestWeekday!.weekday, 2);
    });

    test('rollover moves a night entry to the previous weekday', () async {
      // 01:30 Dhaka on Tuesday the 20th.
      await f.txns.post(f.cashOutDraft(1000, at: dhaka(20, 1)));
      final plain = await compute();
      expect(plain.weekdays[1].count, 1); // Tuesday
      final rolled = await compute(rollover: 4);
      expect(rolled.weekdays[0].count, 1); // Monday's business day
      // The clock hour is unaffected by the rollover.
      expect(rolled.hours[1].count, 1);
    });

    test('voided entries and thin data', () async {
      final id = await f.txns.post(f.cashOutDraft(1000, at: dhaka(19, 10)));
      await f.txns.voidTransaction(id, reason: 'x', userId: 'owner');
      final ins = await compute();
      expect(ins.count, 0);
      expect(ins.averageSize, Money.zero);
      expect(ins.hasEnoughData, isFalse);
      expect(ins.busiestHour, isNull);
      expect(ins.bestWeekday, isNull);
    });
  });
}
