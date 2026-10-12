import 'package:agentkhata/core/i18n/digit_formatter.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/core/money/money_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    test('stores integer paisa and exposes parts', () {
      const m = Money.paisa(123456);
      expect(m.wholeTaka, 1234);
      expect(m.paisaPart, 56);
      expect(const Money.taka(5).paisa, 500);
    });

    test('arithmetic and comparison', () {
      const a = Money.taka(10);
      const b = Money.paisa(250);
      expect((a + b).paisa, 1250);
      expect((a - b).paisa, 750);
      expect((-a).paisa, -1000);
      expect((b * 4).paisa, 1000);
      expect(a > b, isTrue);
      expect(a.compareTo(b), greaterThan(0));
      expect(const Money.paisa(5), const Money.paisa(5));
    });

    test('mulRatio rounds half-up, ties away from zero', () {
      // 1 taka * 5/1000 = 0.5 paisa -> 1 paisa
      expect(const Money.taka(1).mulRatio(5, 1000).paisa, 1);
      // 1 taka * 4/1000 = 0.4 paisa -> 0
      expect(const Money.taka(1).mulRatio(4, 1000).paisa, 0);
      // per-thousand: 2,000 taka * 4.1 per 1000 = 8.20 taka
      expect(const Money.taka(2000).mulRatio(410, 100000).paisa, 820);
      expect(const Money.paisa(-100).mulRatio(5, 1000).paisa, -1);
      expect(() => Money.zero.mulRatio(1, 0), throwsArgumentError);
    });

    test('tryParse', () {
      expect(Money.tryParse('1500')?.paisa, 150000);
      expect(Money.tryParse('1500.5')?.paisa, 150050);
      expect(Money.tryParse('1500.05')?.paisa, 150005);
      expect(Money.tryParse('1,500'), isNull);
      expect(Money.tryParse('abc'), isNull);
      expect(Money.tryParse('1.234'), isNull);
    });
  });

  group('MoneyFormatter', () {
    test('Bangla digits with Bangladeshi grouping', () {
      const f = MoneyFormatter();
      expect(f.format(const Money.taka(123456)), '৳ ১,২৩,৪৫৬');
      expect(f.format(Money.zero), '৳ ০');
    });

    test('Latin digits with international grouping', () {
      const f = MoneyFormatter(
        digits: DigitFormatter(
          style: DigitStyle.latin,
          bangladeshiGrouping: false,
        ),
      );
      expect(f.format(const Money.taka(1234567)), '৳ 1,234,567');
    });

    test('shows paisa only when present in auto mode', () {
      const f = MoneyFormatter(digits: DigitFormatter(style: DigitStyle.latin));
      expect(f.format(const Money.paisa(150050)), '৳ 1,500.50');
      expect(f.format(const Money.paisa(150000)), '৳ 1,500');
      expect(
        const MoneyFormatter(
          digits: DigitFormatter(style: DigitStyle.latin),
          paisaDisplay: PaisaDisplay.always,
        ).format(const Money.taka(7)),
        '৳ 7.00',
      );
    });

    test('negative amounts and no-symbol mode', () {
      const f = MoneyFormatter(
        digits: DigitFormatter(style: DigitStyle.latin),
        showSymbol: false,
      );
      expect(f.format(const Money.taka(-2500)), '-2,500');
    });
  });
}
