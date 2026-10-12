import 'package:agentkhata/core/i18n/digit_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toBangla / toLatin round trip and leave other text alone', () {
    expect(DigitFormatter.toBangla('Tk 0123456789.50'), 'Tk ০১২৩৪৫৬৭৮৯.৫০');
    expect(DigitFormatter.toLatin('০১২৩৪৫৬৭৮৯'), '0123456789');
    expect(DigitFormatter.toLatin('৳ ১,২০০'), '৳ 1,200');
  });

  test('Bangladeshi grouping', () {
    const f = DigitFormatter(style: DigitStyle.latin);
    expect(f.group('1'), '1');
    expect(f.group('999'), '999');
    expect(f.group('1000'), '1,000');
    expect(f.group('100000'), '1,00,000');
    expect(f.group('12345678'), '1,23,45,678');
  });

  test('international grouping', () {
    const f = DigitFormatter(
      style: DigitStyle.latin,
      bangladeshiGrouping: false,
    );
    expect(f.group('100000'), '100,000');
    expect(f.group('1234567'), '1,234,567');
  });

  test('formatInt localizes and handles sign', () {
    expect(const DigitFormatter().formatInt(-100000), '-১,০০,০০০');
  });
}
