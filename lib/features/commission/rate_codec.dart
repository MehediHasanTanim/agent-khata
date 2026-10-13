import 'commission_rule.dart';

/// Converts between what a user types and the stored integer value.
///
/// For every [CommissionMode] the stored value is "hundredths of the
/// displayed unit": ৳4.50 per ৳1,000 -> 450 paisa; 2.5% -> 250 bp; a fixed
/// ৳5 -> 500 paisa. So one decimal parser (max 2 places) serves all modes.
class RateCodec {
  const RateCodec._();

  /// Parses ASCII text like `4`, `4.5`, `0.25`. Null if invalid or negative.
  static int? parse(String input) {
    final m = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(input.trim());
    if (m == null) return null;
    final whole = int.parse(m.group(1)!);
    final frac = (m.group(2) ?? '').padRight(2, '0');
    return whole * 100 + int.parse(frac.isEmpty ? '0' : frac);
  }

  /// Plain ASCII text for [value]: `400` -> `4`, `450` -> `4.5`.
  static String format(int value) {
    final whole = value ~/ 100;
    final frac = value % 100;
    if (frac == 0) return '$whole';
    final f = frac.toString().padLeft(2, '0');
    return '$whole.${f.endsWith('0') ? f.substring(0, 1) : f}';
  }

  /// Sanity ceiling per mode to catch typos (e.g. 50% per-thousand).
  static bool isPlausible(CommissionMode mode, int value) => switch (mode) {
    CommissionMode.perThousand => value <= 100000, // ৳1,000 per ৳1,000
    CommissionMode.percent => value <= 10000, // 100%
    CommissionMode.fixed => value <= 10000000, // ৳100,000
    CommissionMode.tiered => true, // checked per tier
  };
}
