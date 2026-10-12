import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/commission/commission_engine.dart';
import 'package:agentkhata/features/commission/commission_rule.dart';
import 'package:agentkhata/features/commission/commission_rule_repository.dart';
import 'package:agentkhata/features/transactions/transaction_queries.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

void main() {
  late LedgerFixture f;
  late TransactionQueries q;

  setUp(() async {
    f = await LedgerFixture.create();
    q = TransactionQueries(f.db);
  });
  tearDown(() => f.dispose());

  group('queries', () {
    test(
      'recent lists active entries newest first with wallet label',
      () async {
        await f.txns.post(
          f.cashOutDraft(1000, at: DateTime.utc(2026, 10, 20, 8)),
        );
        final id2 = await f.txns.post(
          f.cashInDraft(
            500,
            wallet: f.nagad,
            at: DateTime.utc(2026, 10, 20, 9),
          ),
        );
        final voidMe = await f.txns.post(
          f.cashOutDraft(300, at: DateTime.utc(2026, 10, 20, 9, 30)),
        );
        await f.txns.voidTransaction(voidMe, reason: 'x', userId: 'owner');

        final recent = await q.watchRecent(limit: 5).first;
        expect(recent.map((r) => r.amount.wholeTaka), [500, 1000]);
        expect(recent.first.id, id2);
        expect(recent.first.type, TransactionType.cashIn);
        expect(recent.first.accountLabel, 'Nagad');
        expect(recent.last.accountLabel, 'bKash');
      },
    );

    test('recent honours the limit', () async {
      for (var i = 1; i <= 7; i++) {
        await f.txns.post(
          f.cashOutDraft(i * 100, at: DateTime.utc(2026, 10, 20, i)),
        );
      }
      expect((await q.watchRecent(limit: 5).first), hasLength(5));
    });

    test(
      'day summary counts and sums only the range, ignoring voids',
      () async {
        await f.txns.post(
          f.cashOutDraft(2000, at: DateTime.utc(2026, 10, 20, 8)),
        );
        await f.txns.post(
          f.cashInDraft(500, at: DateTime.utc(2026, 10, 20, 9)),
        );
        await f.txns.post(
          f.cashOutDraft(900, at: DateTime.utc(2026, 10, 19, 8)),
        );
        final gone = await f.txns.post(
          f.cashOutDraft(700, at: DateTime.utc(2026, 10, 20, 10)),
        );
        await f.txns.voidTransaction(gone, reason: 'x', userId: 'owner');

        final s = await q
            .watchSummary(
              DateTime.utc(2026, 10, 19, 18),
              DateTime.utc(2026, 10, 20, 18),
            )
            .first;
        expect(s.count, 2);
        expect(s.cashOutVolume, const Money.taka(2000));
        expect(s.cashInVolume, const Money.taka(500));
        expect(s.commission.paisa, 2000 * 4); // fixture: 4 paisa per taka
      },
    );

    test('frequent amounts: most used first, then most recent', () async {
      Future<void> out(int taka, int hour) => f.txns
          .post(f.cashOutDraft(taka, at: DateTime.utc(2026, 10, 20, hour)))
          .then((_) {});
      await out(1000, 1);
      await out(500, 2);
      await out(1000, 3);
      await out(2000, 4);
      await out(500, 5);
      await out(300, 6);
      final amounts = await q.frequentAmounts(TransactionType.cashOut);
      expect(amounts.map((m) => m.wholeTaka), [500, 1000, 300, 2000]);
      expect(await q.frequentAmounts(TransactionType.cashIn), isEmpty);
    });

    test('last amount', () async {
      expect(await q.lastAmount(TransactionType.cashOut), isNull);
      await f.txns.post(f.cashOutDraft(100, at: DateTime.utc(2026, 10, 20, 1)));
      await f.txns.post(f.cashOutDraft(250, at: DateTime.utc(2026, 10, 20, 2)));
      expect((await q.lastAmount(TransactionType.cashOut))?.wholeTaka, 250);
    });

    test('duplicate detection', () async {
      await f.txns.post(f.cashOutDraft(1000));
      final now = f.clock();
      Future<bool> dup({String? wallet, int taka = 1000, Duration? within}) =>
          q.hasDuplicate(
            type: TransactionType.cashOut,
            amount: Money.taka(taka),
            accountId: wallet ?? f.bkash,
            now: now,
            within: within ?? const Duration(minutes: 2),
          );
      expect(await dup(), isTrue);
      expect(await dup(taka: 1001), isFalse);
      expect(await dup(wallet: f.nagad), isFalse);
      // Outside the window.
      expect(
        await q.hasDuplicate(
          type: TransactionType.cashOut,
          amount: const Money.taka(1000),
          accountId: f.bkash,
          now: now.add(const Duration(minutes: 5)),
        ),
        isFalse,
      );
    });
  });

  group('setRate', () {
    late CommissionRuleRepository rules;
    setUp(() {
      rules = CommissionRuleRepository(f.db, f.ids, f.audit);
    });

    final t0 = DateTime.utc(2000);
    final t1 = DateTime.utc(2026, 10, 20, 12);

    test('first rate, then a dated change keeps history', () async {
      await rules.setRate(
        provider: 'bkash',
        type: TransactionType.cashOut,
        mode: CommissionMode.perThousand,
        value: 400,
        at: t0,
      );
      await rules.setRate(
        provider: 'bkash',
        type: TransactionType.cashOut,
        mode: CommissionMode.perThousand,
        value: 450,
        at: t1,
      );
      final all = await rules.all();
      expect(all, hasLength(2));

      const engine = CommissionEngine();
      Money at(DateTime t) => engine
          .compute(
            rules: all,
            provider: 'bkash',
            type: TransactionType.cashOut,
            amount: const Money.taka(1000),
            at: t,
          )
          .amount;
      expect(at(t1.subtract(const Duration(minutes: 1))).paisa, 400);
      expect(at(t1).paisa, 450);
    });

    test('unchanged rate is a no-op', () async {
      for (var i = 0; i < 2; i++) {
        await rules.setRate(
          provider: 'gp',
          type: TransactionType.flexiload,
          mode: CommissionMode.percent,
          value: 250,
          at: t0.add(Duration(days: i)),
        );
      }
      expect(await rules.all(), hasLength(1));
    });

    test('audits rate changes', () async {
      await rules.setRate(
        provider: 'bkash',
        type: TransactionType.cashOut,
        mode: CommissionMode.fixed,
        value: 500,
        at: t0,
      );
      final audit = await f.db.select(f.db.auditLogs).get();
      expect(audit.map((a) => a.action), contains('rate_change'));
    });
  });
}
