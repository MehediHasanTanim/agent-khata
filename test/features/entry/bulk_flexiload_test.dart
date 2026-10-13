import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/entry/bulk_flexiload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeMobile', () {
    test('strips spaces, dashes, country code and Bangla digits', () {
      expect(normalizeMobile('01712-345 678'), '01712345678');
      expect(normalizeMobile('+8801712345678'), '01712345678');
      expect(normalizeMobile('8801712345678'), '01712345678');
      expect(normalizeMobile('০১৭১২৩৪৫৬৭৮'), '01712345678');
    });

    test('validity', () {
      expect(isValidBdMobile('01712345678'), isTrue);
      expect(isValidBdMobile('01212345678'), isFalse); // 012 is not a mobile
      expect(isValidBdMobile('1712345678'), isFalse);
      expect(isValidBdMobile('0171234567'), isFalse);
    });
  });

  group('parseBulkLines', () {
    test('number and amount in either order, various separators', () {
      final r = parseBulkLines('''
01712345678 100
20 01911222333
01611111111, 50
''');
      expect(r.rejected, isEmpty);
      expect(r.rows.map((x) => x.number), [
        '01712345678',
        '01911222333',
        '01611111111',
      ]);
      expect(r.rows.map((x) => x.amount!.wholeTaka), [100, 20, 50]);
    });

    test('Bangla digits and +88 prefixes', () {
      final r = parseBulkLines('০১৭১২৩৪৫৬৭৮ ৫০\n+8801811111111 ১০০');
      expect(r.rows.map((x) => x.number), ['01712345678', '01811111111']);
      expect(r.rows.map((x) => x.amount!.wholeTaka), [50, 100]);
    });

    test('an amount alone is allowed; garbage lines are reported', () {
      final r = parseBulkLines('100\nhello world\n01712345678\n\n  30  ');
      expect(r.rows.map((x) => x.amount!.wholeTaka), [100, 30]);
      expect(r.rows.first.number, '');
      expect(r.rejected, ['hello world', '01712345678']);
    });

    test('decimal amounts are kept', () {
      final r = parseBulkLines('01712345678 99.50');
      expect(r.rows.single.amount, const Money.paisa(9950));
    });
  });

  test('duplicate detection flags repeats of number and amount', () {
    final rows = [
      const BulkRow(number: '01712345678', amount: Money.taka(100)),
      const BulkRow(number: '+8801712345678', amount: Money.taka(100)),
      const BulkRow(number: '01712345678', amount: Money.taka(50)),
      const BulkRow(amount: Money.taka(100)),
      const BulkRow(amount: Money.taka(100)), // no number: never a duplicate
    ];
    expect(duplicateRowIndexes(rows), {1});
  });

  test('row completeness', () {
    expect(const BulkRow().isBlank, isTrue);
    expect(const BulkRow(number: '017').isComplete, isFalse);
    expect(const BulkRow(amount: Money.taka(10)).isComplete, isTrue);
    expect(const BulkRow(amount: Money.zero).isComplete, isFalse);
  });
}
