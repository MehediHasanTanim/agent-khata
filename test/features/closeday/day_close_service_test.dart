import 'package:agentkhata/core/audit/audit_logger.dart';
import 'package:agentkhata/core/db/db_settings.dart';
import 'package:agentkhata/core/ledger/transaction_draft.dart';
import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/closeday/day_close_service.dart';
import 'package:agentkhata/features/transactions/history_filter.dart';
import 'package:agentkhata/features/transactions/history_queries.dart';
import 'package:agentkhata/features/transactions/integrity_checker.dart';
import 'package:agentkhata/features/transactions/transaction_repository.dart';

import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

void main() {
  late LedgerFixture f;
  late DayCloseService service;

  // Fixture clock is 2026-10-20 10:00 UTC (16:00 Dhaka). Business date with
  // rollover 0 is 2026-10-20.
  const date = '2026-10-20';

  setUp(() async {
    f = await LedgerFixture.create();
    await DbSettings(f.db).set(DbSettings.dayRolloverHourKey, '0');
    service = DayCloseService(
      db: f.db,
      txns: f.txns,
      audit: AuditLogger(f.db, f.ids, clock: f.clock),
      ids: f.ids,
      clock: f.clock,
    );
  });
  tearDown(() => f.dispose());

  DateTime at(int hour) => DateTime.utc(2026, 10, 20, hour);

  Future<void> trade() async {
    await f.txns.post(
      f.cashOutDraft(2000, at: at(5)),
    ); // cash 8000, bkash 52000
    await f.txns.post(f.cashInDraft(500, at: at(6))); // cash 8500, bkash 51500
  }

  test('preview: expected balances come from the ledger', () async {
    await trade();
    final p = await service.preview(date);
    final byId = {for (final a in p.accounts) a.account.id: a.expected};
    expect(byId[f.cash], const Money.taka(8500));
    expect(byId[f.bkash], const Money.taka(51500));
    expect(p.status, isNull);
    // Entries of the day on counted accounts only.
    expect(p.entries.map((e) => e.deltaPaisa).toSet(), {
      -200000,
      200000,
      50000,
      -50000,
    });
  });

  test('later days do not change expected for this day', () async {
    await trade();
    await f.txns.post(f.cashOutDraft(100, at: DateTime.utc(2026, 10, 21, 9)));
    final p = await service.preview(date);
    final cash = p.accounts.firstWhere((a) => a.account.id == f.cash);
    expect(cash.expected, const Money.taka(8500));
  });

  test('clean close: no adjustments, day locked, snapshots written', () async {
    await trade();
    final id = await service.close(businessDate: date, actuals: const {});
    final row = await (f.db.select(
      f.db.dayCloses,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(row.status, 'closed');

    final adj = await (f.db.select(
      f.db.txns,
    )..where((t) => t.type.equals('adjustment'))).get();
    expect(adj, isEmpty);

    final locked = await (f.db.select(
      f.db.txns,
    )..where((t) => t.dayCloseId.equals(id))).get();
    expect(locked, hasLength(2));

    final snaps = await f.db.select(f.db.balanceSnapshots).get();
    expect(snaps.length, greaterThanOrEqualTo(5));
    final cashSnap = snaps.firstWhere((s) => s.accountId == f.cash);
    expect(cashSnap.balancePaisa, 850000);
  });

  test('variance needs a reason; with one it is adjusted', () async {
    await trade();
    await expectLater(
      service.close(
        businessDate: date,
        actuals: {f.cash: const Money.taka(8000)},
      ),
      throwsA(isA<MissingVarianceReason>()),
    );
    // Nothing was written by the failed attempt.
    expect(await f.db.select(f.db.dayCloses).get(), isEmpty);

    await service.close(
      businessDate: date,
      actuals: {f.cash: const Money.taka(8000)},
      resolutions: {
        f.cash: const VarianceResolution(
          AdjustmentReason.shortage,
          text: 'torn notes',
        ),
      },
    );
    expect(await f.accounts.balanceOf(f.cash), const Money.taka(8000));

    final adj = await (f.db.select(
      f.db.txns,
    )..where((t) => t.type.equals('adjustment'))).getSingle();
    expect(adj.note, 'shortage: torn notes');
    expect(adj.amountPaisa, 50000);

    final lines = await f.db.select(f.db.dayCloseLines).get();
    final cashLine = lines.firstWhere((l) => l.accountId == f.cash);
    expect(cashLine.expectedPaisa, 850000);
    expect(cashLine.actualPaisa, 800000);
    expect(cashLine.variancePaisa, -50000);
    expect(cashLine.adjustmentTxnId, adj.id);
  });

  test('excess is adjusted upward', () async {
    await trade();
    await service.close(
      businessDate: date,
      actuals: {f.bkash: const Money.taka(51600)},
      resolutions: {f.bkash: const VarianceResolution(AdjustmentReason.excess)},
    );
    expect(await f.accounts.balanceOf(f.bkash), const Money.taka(51600));
  });

  test('tolerance writes small variances off automatically', () async {
    await trade();
    await service.close(
      businessDate: date,
      actuals: {f.cash: const Money.taka(8497)},
      toleranceTaka: 5,
    );
    final adj = await (f.db.select(
      f.db.txns,
    )..where((t) => t.type.equals('adjustment'))).getSingle();
    expect(adj.note, 'tolerance');
    expect(await f.accounts.balanceOf(f.cash), const Money.taka(8497));
  });

  test('closing twice is idempotent', () async {
    await trade();
    final a = await service.close(businessDate: date, actuals: const {});
    final b = await service.close(businessDate: date, actuals: const {});
    expect(b, a);
    expect(await f.db.select(f.db.dayCloses).get(), hasLength(1));
  });

  test('closed day refuses new, void and edit', () async {
    await trade();
    final id = await f.txns.post(f.cashOutDraft(10, at: at(7)));
    await service.close(businessDate: date, actuals: const {});
    await expectLater(
      f.txns.post(f.cashOutDraft(10, at: at(8))),
      throwsA(isA<DayLockedException>()),
    );
    await expectLater(
      f.txns.voidTransaction(id, reason: 'x', userId: 'owner'),
      throwsA(isA<DayLockedException>()),
    );
    final item = await HistoryQueries(f.db).byId(id);
    expect(item!.isLocked, isTrue);
  });

  test('reopen, correct and re-close gives identical results', () async {
    await trade();
    final actuals = {f.cash: const Money.taka(8000)};
    final resolutions = {
      f.cash: const VarianceResolution(AdjustmentReason.shortage),
    };
    final id = await service.close(
      businessDate: date,
      actuals: actuals,
      resolutions: resolutions,
    );
    final before = await f.accounts.balances();

    await service.reopen(date, reason: 'forgot an entry');
    // While reopened the adjustment is void and the ledger shows the books.
    expect(await f.accounts.balanceOf(f.cash), const Money.taka(8500));
    final item = await HistoryQueries(f.db).page(const HistoryFilter());
    expect(item.where((i) => i.isLocked), isEmpty);

    final id2 = await service.close(
      businessDate: date,
      actuals: actuals,
      resolutions: resolutions,
    );
    expect(id2, id);
    expect(await f.accounts.balances(), before);

    final line = (await f.db.select(f.db.dayCloseLines).get()).firstWhere(
      (l) => l.accountId == f.cash,
    );
    expect(line.variancePaisa, -50000);
    expect(
      await LedgerIntegrityChecker(f.db).run().then((r) => r.isHealthy),
      isTrue,
    );
  });

  test('reopen allows an extra entry, then re-close includes it', () async {
    await trade();
    await service.close(businessDate: date, actuals: const {});
    await service.reopen(date, reason: 'missed one');
    await f.txns.post(f.cashOutDraft(300, at: at(9)));
    await service.close(
      businessDate: date,
      actuals: {f.cash: const Money.taka(8200)},
    );
    final locked = (await f.db.select(f.db.txns).get()).where(
      (t) => t.dayCloseId != null,
    );
    expect(locked, hasLength(3));
    expect(await f.accounts.balanceOf(f.cash), const Money.taka(8200));
  });

  test('only the latest closed day can be reopened; reason required', () async {
    final later = DayCloseService(
      db: f.db,
      txns: f.txns,
      audit: AuditLogger(f.db, f.ids, clock: f.clock),
      ids: f.ids,
      clock: () => DateTime.utc(2026, 10, 22, 12),
    );
    await trade();
    await f.txns.post(f.cashOutDraft(100, at: DateTime.utc(2026, 10, 21, 8)));
    await later.close(businessDate: date, actuals: const {});
    await later.close(businessDate: '2026-10-21', actuals: const {});
    await expectLater(
      later.reopen(date, reason: 'x'),
      throwsA(
        isA<DayCloseException>().having(
          (e) => e.code,
          'code',
          'later_day_closed',
        ),
      ),
    );
    expect(() => later.reopen('2026-10-21', reason: ' '), throwsArgumentError);
    await later.reopen('2026-10-21', reason: 'ok');
  });

  test('closing a future day is refused', () async {
    await expectLater(
      service.close(businessDate: '2026-10-25', actuals: const {}),
      throwsA(isA<DayCloseException>()),
    );
  });

  test(
    'snapshot-based balances equal a full recompute under mutations',
    () async {
      await trade();
      await service.close(businessDate: date, actuals: const {});
      // Mutations after the snapshot: new entry, then a void of an older one.
      final newer = await f.txns.post(
        f.cashOutDraft(100, at: DateTime.utc(2026, 10, 21, 8)),
      );
      final report1 = await LedgerIntegrityChecker(f.db).run();
      expect(report1.isHealthy, isTrue);
      expect(await f.accounts.balanceOf(f.cash), const Money.taka(8400));

      await f.txns.voidTransaction(newer, reason: 'x', userId: 'owner');
      expect(await f.accounts.balanceOf(f.cash), const Money.taka(8500));

      // Void an entry older than the snapshot via reopen: snapshot invalidated.
      await service.reopen(date, reason: 'fix');
      final old = (await f.db.select(f.db.txns).get()).firstWhere(
        (t) => t.type == 'cash_out' && t.amountPaisa == 200000,
      );
      await f.txns.voidTransaction(old.id, reason: 'wrong', userId: 'owner');
      expect(await f.accounts.balanceOf(f.cash), const Money.taka(10500));
      expect(
        await LedgerIntegrityChecker(f.db).run().then((r) => r.isHealthy),
        isTrue,
      );
    },
  );

  test(
    'daily summary: volumes, commission, margin, expenses, net profit',
    () async {
      await f.txns.post(f.cashOutDraft(2000, at: at(5))); // commission 80
      await f.txns.post(f.cashInDraft(500, at: at(6)));
      await f.txns.post(
        TransactionDraft(
          type: TransactionType.flexiload,
          occurredAt: at(7),
          amount: const Money.taka(100),
          fromAccountId: f.gpLoad,
          toAccountId: f.cash,
          commission: const Money.taka(3),
        ),
      );
      await f.txns.post(
        TransactionDraft(
          type: TransactionType.expense,
          occurredAt: at(8),
          amount: const Money.taka(20),
          fromAccountId: f.cash,
          toAccountId: f.rent,
        ),
      );

      var s = await service.summary(date);
      expect(s.count, 4);
      expect(s.cashOutVolume, const Money.taka(2000));
      expect(s.cashInVolume, const Money.taka(500));
      expect(s.commission.paisa, 8000);
      expect(s.flexiloadMargin, const Money.taka(3));
      expect(s.expenses, const Money.taka(20));
      expect(s.netProfit.paisa, 8000 + 300 - 2000);
      expect(s.status, isNull);
      expect(s.totalVariance, isNull);

      final cash = s.accounts.firstWhere((a) => a.label == 'Cash');
      expect(cash.opening, const Money.taka(10000));
      expect(cash.expected, const Money.taka(8580));
      expect(cash.actual, isNull);

      await service.close(
        businessDate: date,
        actuals: {f.cash: const Money.taka(8570)},
        resolutions: {
          f.cash: const VarianceResolution(AdjustmentReason.countingError),
        },
      );
      s = await service.summary(date);
      expect(s.status, 'closed');
      expect(s.totalVariance, const Money.taka(-10));
      final closedCash = s.accounts.firstWhere((a) => a.label == 'Cash');
      expect(closedCash.variance, const Money.taka(-10));
      // Adjustments do not count as business volume.
      expect(s.count, 4);
    },
  );
}
