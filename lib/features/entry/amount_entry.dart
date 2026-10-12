import '../../core/money/money.dart';

/// Pure state machine behind the numeric keypad. Whole taka only.
///
/// Digits are always ASCII internally; localization is a display concern.
class AmountEntry {
  const AmountEntry([this.digits = '']);

  /// Longest accepted amount (৳99,99,99,999).
  static const maxDigits = 9;

  final String digits;

  Money get amount =>
      digits.isEmpty ? Money.zero : Money.taka(int.parse(digits));

  bool get isEmpty => digits.isEmpty;

  AmountEntry press(String key) {
    if (key == '000') {
      if (digits.isEmpty) return this; // avoid leading zeros
      return _append('000');
    }
    if (key.length == 1 &&
        key.codeUnitAt(0) >= 0x30 &&
        key.codeUnitAt(0) <= 0x39) {
      if (digits.isEmpty && key == '0') return this;
      return _append(key);
    }
    throw ArgumentError.value(key, 'key', 'not a keypad key');
  }

  AmountEntry backspace() => digits.isEmpty
      ? this
      : AmountEntry(digits.substring(0, digits.length - 1));

  AmountEntry clear() => const AmountEntry();

  /// Replaces the entry with [money] rounded down to whole taka.
  AmountEntry set(Money money) => money.isPositive
      ? AmountEntry('${money.wholeTaka}')
      : const AmountEntry();

  AmountEntry _append(String s) {
    final next = digits + s;
    return next.length > maxDigits ? this : AmountEntry(next);
  }
}
