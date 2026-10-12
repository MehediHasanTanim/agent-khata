import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/entry/amount_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds an amount digit by digit', () {
    var e = const AmountEntry();
    expect(e.amount, Money.zero);
    e = e.press('2').press('5').press('0');
    expect(e.digits, '250');
    expect(e.amount, const Money.taka(250));
  });

  test('"000" appends three zeros but never creates leading zeros', () {
    expect(const AmountEntry().press('000').digits, '');
    expect(const AmountEntry().press('0').digits, '');
    expect(
      const AmountEntry().press('5').press('000').amount,
      const Money.taka(5000),
    );
  });

  test('backspace and clear', () {
    final e = const AmountEntry('1250');
    expect(e.backspace().digits, '125');
    expect(const AmountEntry().backspace().digits, '');
    expect(e.clear().isEmpty, isTrue);
  });

  test('caps at nine digits', () {
    final e = const AmountEntry('999999999');
    expect(e.press('1').digits, '999999999');
    expect(const AmountEntry('9999999').press('000').digits, '9999999');
  });

  test('set() takes whole taka from a chip', () {
    expect(const AmountEntry().set(const Money.taka(2000)).digits, '2000');
    expect(const AmountEntry('5').set(Money.zero).isEmpty, isTrue);
  });

  test('rejects non-keypad keys', () {
    expect(() => const AmountEntry().press('x'), throwsArgumentError);
  });
}
