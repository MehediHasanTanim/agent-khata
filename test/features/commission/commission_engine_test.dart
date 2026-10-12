import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/commission/commission_engine.dart';
import 'package:agentkhata/features/commission/commission_rule.dart';
import 'package:flutter_test/flutter_test.dart';

CommissionRule _rule(
  String id,
  CommissionMode mode,
  int value,
  DateTime from, {
  DateTime? to,
  String provider = 'bkash',
  TransactionType type = TransactionType.cashOut,
}) => CommissionRule(
  id: id,
  provider: provider,
  txnType: type,
  mode: mode,
  value: value,
  effectiveFrom: from,
  effectiveTo: to,
);

void main() {
  const engine = CommissionEngine();
  final jan = DateTime.utc(2026, 1, 1);
  final jul = DateTime.utc(2026, 7, 1);
  final at = DateTime.utc(2026, 10, 20, 10);

  group('modes', () {
    test('per thousand: 410 paisa per ৳1,000 on ৳2,000 = ৳8.20', () {
      final r = _rule('r', CommissionMode.perThousand, 410, jan);
      expect(engine.apply(r, const Money.taka(2000)).paisa, 820);
    });

    test('percent in basis points: 1.5% of ৳1,000 = ৳15', () {
      final r = _rule('r', CommissionMode.percent, 150, jan);
      expect(engine.apply(r, const Money.taka(1000)).paisa, 1500);
    });

    test('fixed paisa', () {
      final r = _rule('r', CommissionMode.fixed, 500, jan);
      expect(engine.apply(r, const Money.taka(999)).paisa, 500);
    });
  });

  group('rounding (half-up to the paisa)', () {
    // 0.5 paisa rounds up, 0.4 down.
    test('ties round up', () {
      final r = _rule('r', CommissionMode.perThousand, 5, jan);
      expect(engine.apply(r, const Money.taka(100)).paisa, 1); // 0.5
    });
    test('below half rounds down', () {
      final r = _rule('r', CommissionMode.perThousand, 4, jan);
      expect(engine.apply(r, const Money.taka(100)).paisa, 0); // 0.4
    });
    test('1.5 paisa rounds to 2', () {
      final r = _rule('r', CommissionMode.perThousand, 15, jan);
      expect(engine.apply(r, const Money.taka(100)).paisa, 2);
    });
  });

  group('rule selection', () {
    test('matches provider and type', () {
      final rules = [
        _rule('a', CommissionMode.fixed, 100, jan),
        _rule('b', CommissionMode.fixed, 200, jan, provider: 'nagad'),
        _rule(
          'c',
          CommissionMode.fixed,
          300,
          jan,
          type: TransactionType.cashIn,
        ),
      ];
      final r = engine.selectRule(
        rules,
        provider: 'nagad',
        type: TransactionType.cashOut,
        at: at,
      );
      expect(r?.id, 'b');
    });

    test('latest effectiveFrom wins; effectiveTo is exclusive', () {
      final rules = [
        _rule('old', CommissionMode.fixed, 100, jan, to: jul),
        _rule('new', CommissionMode.fixed, 200, jul),
      ];
      String? pick(DateTime t) => engine
          .selectRule(
            rules,
            provider: 'bkash',
            type: TransactionType.cashOut,
            at: t,
          )
          ?.id;
      expect(pick(DateTime.utc(2026, 6, 30, 23, 59)), 'old');
      expect(pick(jul), 'new');
      expect(pick(DateTime.utc(2025, 12, 31)), isNull);
    });

    test('mid-day rate change applies per transaction time', () {
      final change = DateTime.utc(2026, 10, 20, 12);
      final rules = [
        _rule('am', CommissionMode.perThousand, 400, jan, to: change),
        _rule('pm', CommissionMode.perThousand, 450, change),
      ];
      Money commission(DateTime t) => engine
          .compute(
            rules: rules,
            provider: 'bkash',
            type: TransactionType.cashOut,
            amount: const Money.taka(1000),
            at: t,
          )
          .amount;
      expect(commission(DateTime.utc(2026, 10, 20, 11, 59)).paisa, 400);
      expect(commission(DateTime.utc(2026, 10, 20, 12)).paisa, 450);
    });
  });

  group('compute', () {
    final rules = [_rule('r1', CommissionMode.perThousand, 410, jan)];

    test('snapshots the rule id', () {
      final res = engine.compute(
        rules: rules,
        provider: 'bkash',
        type: TransactionType.cashOut,
        amount: const Money.taka(2000),
        at: at,
      );
      expect(res.amount.paisa, 820);
      expect(res.ruleId, 'r1');
      expect(res.overridden, isFalse);
    });

    test('manual override wins and is flagged', () {
      final res = engine.compute(
        rules: rules,
        provider: 'bkash',
        type: TransactionType.cashOut,
        amount: const Money.taka(2000),
        at: at,
        override: const Money.taka(10),
      );
      expect(res.amount.paisa, 1000);
      expect(res.overridden, isTrue);
    });

    test('no matching rule yields zero', () {
      final res = engine.compute(
        rules: rules,
        provider: 'rocket',
        type: TransactionType.cashOut,
        amount: const Money.taka(2000),
        at: at,
      );
      expect(res.amount, Money.zero);
      expect(res.ruleId, isNull);
    });
  });
}
