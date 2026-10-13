import '../../core/i18n/digit_formatter.dart';
import '../../core/money/money.dart';

/// One load to send: an (optional) customer number and the price charged.
class BulkRow {
  const BulkRow({this.number = '', this.amount});

  final String number;
  final Money? amount;

  bool get isBlank => number.trim().isEmpty && amount == null;
  bool get isComplete => amount != null && amount!.isPositive;
}

/// Digits only, Bangla digits converted, `+88` / `88` country code removed.
String normalizeMobile(String raw) {
  var v = DigitFormatter.toLatin(raw).replaceAll(RegExp(r'[^0-9+]'), '');
  if (v.startsWith('+88')) {
    v = v.substring(3);
  } else if (v.startsWith('88') && v.length == 13) {
    v = v.substring(2);
  }
  return v.replaceAll('+', '');
}

/// A Bangladeshi mobile number: `01` + operator digit 3-9 + 8 digits.
bool isValidBdMobile(String normalized) =>
    RegExp(r'^01[3-9]\d{8}$').hasMatch(normalized);

class BulkParseResult {
  const BulkParseResult(this.rows, this.rejected);

  final List<BulkRow> rows;

  /// Non-empty lines that had no usable amount.
  final List<String> rejected;
}

/// Parses pasted text such as
/// ```
/// 01712345678 100
/// 20 01911222333
/// 01611111111, 50
/// ```
/// Each line holds a number and an amount in either order. The number is
/// the token that looks like a phone number (11 digits); the amount is the
/// other. A line with only an amount is accepted without a number.
BulkParseResult parseBulkLines(String text) {
  final rows = <BulkRow>[];
  final rejected = <String>[];
  for (final raw in text.split(RegExp(r'[\r\n]+'))) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    final tokens = DigitFormatter.toLatin(line)
        .split(RegExp(r'[\s,;:|]+'))
        .where((t) => t.isNotEmpty)
        .toList();

    String? number;
    Money? amount;
    for (final t in tokens) {
      final digits = normalizeMobile(t);
      if (number == null && RegExp(r'^\d{10,13}$').hasMatch(digits)) {
        number = digits;
        continue;
      }
      amount ??= Money.tryParse(t.replaceAll('৳', ''));
    }
    if (amount == null || !amount.isPositive) {
      rejected.add(line);
    } else {
      rows.add(BulkRow(number: number ?? '', amount: amount));
    }
  }
  return BulkParseResult(rows, rejected);
}

/// Indexes of rows that repeat an earlier row's number and amount.
Set<int> duplicateRowIndexes(List<BulkRow> rows) {
  final seen = <String>{};
  final dups = <int>{};
  for (var i = 0; i < rows.length; i++) {
    final r = rows[i];
    if (r.number.trim().isEmpty || r.amount == null) continue;
    final key = '${normalizeMobile(r.number)}|${r.amount!.paisa}';
    if (!seen.add(key)) dups.add(i);
  }
  return dups;
}
