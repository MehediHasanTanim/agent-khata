import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/commission/commission_rule.dart';
import 'package:agentkhata/features/commission/rate_codec.dart';
import 'package:agentkhata/features/transactions/entry_guards.dart';
import 'package:agentkhata/features/transactions/quick_amounts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mergeQuickAmounts', () {
    test('learned amounts come first, then defaults, no duplicates', () {
      final merged = mergeQuickAmounts([
        const Money.taka(1500),
        const Money.taka(1000),
      ]);
      expect(merged, [
        const Money.taka(1500),
        const Money.taka(1000),
        const Money.taka(500),
        const Money.taka(2000),
      ]);
    });

    test('falls back to defaults when nothing was learned', () {
      expect(mergeQuickAmounts(const []), defaultQuickAmounts);
    });

    test('respects the chip count', () {
      final learned = [for (var i = 1; i <= 6; i++) Money.taka(i * 100)];
      expect(mergeQuickAmounts(learned, count: 3), learned.take(3).toList());
    });
  });

  group('evaluateEntry', () {
    const threshold = Money.taka(50000);

    EntryChecks check({
      int amount = 1000,
      int balance = 5000,
      bool dup = false,
    }) => evaluateEntry(
      amount: Money.taka(amount),
      sourceBalance: Money.taka(balance),
      largeThreshold: threshold,
      duplicateFound: dup,
    );

    test('clean entry', () {
      expect(check().hasAny, isFalse);
    });

    test('flags a source that would go negative, but only that', () {
      final c = check(amount: 6000);
      expect(c.sourceGoesNegative, isTrue);
      expect(c.needsConfirmation, isFalse);
    });

    test('exactly emptying the source is fine', () {
      expect(check(amount: 5000).sourceGoesNegative, isFalse);
    });

    test('large amount and duplicates need confirmation', () {
      expect(check(amount: 50000, balance: 90000).isLarge, isTrue);
      expect(check(amount: 49999, balance: 90000).isLarge, isFalse);
      expect(check(dup: true).needsConfirmation, isTrue);
    });

    test('no warnings for a zero amount', () {
      expect(check(amount: 0, balance: 0).sourceGoesNegative, isFalse);
    });
  });

  group('RateCodec', () {
    test('parse', () {
      expect(RateCodec.parse('4'), 400);
      expect(RateCodec.parse('4.5'), 450);
      expect(RateCodec.parse('0.25'), 25);
      expect(RateCodec.parse(' 12 '), 1200);
      expect(RateCodec.parse('4.567'), isNull);
      expect(RateCodec.parse('-1'), isNull);
      expect(RateCodec.parse(''), isNull);
      expect(RateCodec.parse('abc'), isNull);
    });

    test('format round-trips', () {
      for (final v in [0, 5, 25, 400, 450, 1999, 100000]) {
        expect(RateCodec.parse(RateCodec.format(v)), v);
      }
      expect(RateCodec.format(400), '4');
      expect(RateCodec.format(450), '4.5');
      expect(RateCodec.format(5), '0.05');
    });

    test('plausibility ceilings', () {
      expect(RateCodec.isPlausible(CommissionMode.percent, 10000), isTrue);
      expect(RateCodec.isPlausible(CommissionMode.percent, 10001), isFalse);
      expect(
        RateCodec.isPlausible(CommissionMode.perThousand, 100001),
        isFalse,
      );
    });
  });
}
