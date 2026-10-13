import 'package:agentkhata/core/audit/audit_logger.dart';
import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/commission/commission_engine.dart';
import 'package:agentkhata/features/commission/commission_rule.dart';
import 'package:agentkhata/features/commission/commission_rule_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

CommissionTier _tier(int? upToTaka, CommissionMode mode, int value) =>
    CommissionTier(
      upTo: upToTaka == null ? null : Money.taka(upToTaka),
      mode: mode,
      value: value,
    );

void main() {
  const engine = CommissionEngine();

  // Up to 1,000: ৳5 flat. Up to 5,000: ৳4 per 1,000. Above: 0.3%.
  final tiers = [
    _tier(1000, CommissionMode.fixed, 500),
    _tier(5000, CommissionMode.perThousand, 400),
    _tier(null, CommissionMode.percent, 30),
  ];
  final rule = CommissionRule(
    id: 'r',
    provider: 'bkash',
    txnType: TransactionType.cashOut,
    mode: CommissionMode.tiered,
    value: 0,
    effectiveFrom: DateTime.utc(2000),
    tiers: tiers,
  );

  group('selection', () {
    test('picks the band that contains the amount; bounds are inclusive', () {
      // 1,000 falls in the first band (flat 5.00).
      expect(engine.apply(rule, const Money.taka(1000)).paisa, 500);
      // 1,001 moves to the second band: 4.00 per 1,000 => 4.004 -> 4.00.
      expect(engine.apply(rule, const Money.taka(1001)).paisa, 400);
      expect(engine.apply(rule, const Money.taka(5000)).paisa, 2000);
      // Above 5,000: 0.30% of 10,000 = 30.00.
      expect(engine.apply(rule, const Money.taka(10000)).paisa, 3000);
    });

    test('a small amount uses the first band', () {
      expect(engine.apply(rule, const Money.taka(10)).paisa, 500);
    });

    test('an empty or exhausted tier list never throws', () {
      final empty = CommissionRule(
        id: 'e',
        provider: 'x',
        txnType: TransactionType.cashOut,
        mode: CommissionMode.tiered,
        value: 0,
        effectiveFrom: DateTime.utc(2000),
      );
      expect(engine.apply(empty, const Money.taka(100)), Money.zero);

      final capped = CommissionRule(
        id: 'c',
        provider: 'x',
        txnType: TransactionType.cashOut,
        mode: CommissionMode.tiered,
        value: 0,
        effectiveFrom: DateTime.utc(2000),
        tiers: [_tier(100, CommissionMode.fixed, 700)],
      );
      // 500 is above the only bound: the last band still applies.
      expect(engine.apply(capped, const Money.taka(500)).paisa, 700);
    });

    test('compute() snapshots the rule and honours overrides', () {
      final res = engine.compute(
        rules: [rule],
        provider: 'bkash',
        type: TransactionType.cashOut,
        amount: const Money.taka(2000),
        at: DateTime.utc(2026),
      );
      expect(res.amount.paisa, 800);
      expect(res.ruleId, 'r');
      final over = engine.compute(
        rules: [rule],
        provider: 'bkash',
        type: TransactionType.cashOut,
        amount: const Money.taka(2000),
        at: DateTime.utc(2026),
        override: const Money.taka(1),
      );
      expect(over.overridden, isTrue);
    });
  });

  group('validation and serialization', () {
    test('valid list', () => expect(validateTiers(tiers), isNull));

    test('rejects the bad shapes', () {
      expect(validateTiers(const []), 'empty');
      expect(
        validateTiers([_tier(100, CommissionMode.fixed, 1)]),
        'last_not_open',
      );
      expect(
        validateTiers([
          _tier(null, CommissionMode.fixed, 1),
          _tier(null, CommissionMode.fixed, 1),
        ]),
        'open_in_middle',
      );
      expect(
        validateTiers([
          _tier(500, CommissionMode.fixed, 1),
          _tier(500, CommissionMode.fixed, 2),
          _tier(null, CommissionMode.fixed, 3),
        ]),
        'not_ascending',
      );
      expect(
        validateTiers([
          _tier(0, CommissionMode.fixed, 1),
          _tier(null, CommissionMode.fixed, 3),
        ]),
        'bound_not_positive',
      );
    });

    test('json round trip', () {
      expect(decodeTiers(encodeTiers(tiers)), tiers);
      expect(decodeTiers(null), isEmpty);
      expect(decodeTiers(''), isEmpty);
    });
  });

  group('repository', () {
    late LedgerFixture f;
    late CommissionRuleRepository rules;

    setUp(() async {
      f = await LedgerFixture.create();
      rules = CommissionRuleRepository(
        f.db,
        f.ids,
        AuditLogger(f.db, f.ids, clock: f.clock),
      );
    });
    tearDown(() => f.dispose());

    Future<void> setTiers(List<CommissionTier> t, DateTime at) => rules.setRate(
      provider: 'bkash',
      type: TransactionType.cashOut,
      mode: CommissionMode.tiered,
      value: 0,
      tiers: t,
      at: at,
    );

    test('stores and reloads tiers', () async {
      await setTiers(tiers, DateTime.utc(2000));
      final stored = (await rules.all()).single;
      expect(stored.mode, CommissionMode.tiered);
      expect(stored.tiers, tiers);
      expect(engine.apply(stored, const Money.taka(2000)).paisa, 800);
    });

    test(
      'same tiers again is a no-op; changed tiers start a new rule',
      () async {
        await setTiers(tiers, DateTime.utc(2000));
        await setTiers(tiers, DateTime.utc(2026, 5));
        expect(await rules.all(), hasLength(1));

        final changed = [
          _tier(2000, CommissionMode.fixed, 600),
          _tier(null, CommissionMode.percent, 50),
        ];
        await setTiers(changed, DateTime.utc(2026, 6));
        final all = await rules.all();
        expect(all, hasLength(2));

        Money at(DateTime t) => engine
            .compute(
              rules: all,
              provider: 'bkash',
              type: TransactionType.cashOut,
              amount: const Money.taka(1500),
              at: t,
            )
            .amount;
        expect(at(DateTime.utc(2026, 5, 20)).paisa, 600); // 4.00 x 1.5 = 6.00
        expect(at(DateTime.utc(2026, 6, 1)).paisa, 600); // fixed 6.00
      },
    );

    test('switching between flat and tiered works both ways', () async {
      await rules.setRate(
        provider: 'bkash',
        type: TransactionType.cashOut,
        mode: CommissionMode.perThousand,
        value: 400,
        at: DateTime.utc(2000),
      );
      await setTiers(tiers, DateTime.utc(2026, 3));
      await rules.setRate(
        provider: 'bkash',
        type: TransactionType.cashOut,
        mode: CommissionMode.fixed,
        value: 100,
        at: DateTime.utc(2026, 4),
      );
      final all = await rules.all();
      expect(all, hasLength(3));
      expect(all.where((r) => r.tiers.isNotEmpty), hasLength(1));
    });

    test('invalid tier lists are refused', () async {
      await expectLater(
        setTiers([_tier(100, CommissionMode.fixed, 1)], DateTime.utc(2000)),
        throwsArgumentError,
      );
      expect(await rules.all(), isEmpty);
    });
  });
}
