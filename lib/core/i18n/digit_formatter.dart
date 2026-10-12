/// Which digit glyphs to show in the UI.
enum DigitStyle { bangla, latin }

/// Converts between ASCII digits (0-9) and Bangla digits (০-৯) and applies
/// digit grouping.
///
/// Display uses the chosen [DigitStyle]; input is always normalized back to
/// ASCII with [toLatin] so storage and arithmetic are unaffected.
class DigitFormatter {
  const DigitFormatter({
    this.style = DigitStyle.bangla,
    this.bangladeshiGrouping = true,
  });

  final DigitStyle style;

  /// `true`: 1,00,000 (last three digits, then pairs). `false`: 100,000.
  final bool bangladeshiGrouping;

  static const _banglaDigits = '০১২৩৪৫৬৭৮৯';

  /// Replaces every ASCII digit in [input] with its Bangla equivalent.
  static String toBangla(String input) {
    final buffer = StringBuffer();
    for (final unit in input.codeUnits) {
      if (unit >= 0x30 && unit <= 0x39) {
        buffer.write(_banglaDigits[unit - 0x30]);
      } else {
        buffer.writeCharCode(unit);
      }
    }
    return buffer.toString();
  }

  /// Replaces every Bangla digit in [input] with its ASCII equivalent.
  static String toLatin(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final index = _banglaDigits.runes.toList().indexOf(rune);
      if (index >= 0) {
        buffer.write(index);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// Applies digit grouping to a string of ASCII digits (no sign, no
  /// fraction).
  String group(String asciiDigits) {
    if (asciiDigits.length <= 3) return asciiDigits;
    final head = asciiDigits.substring(0, asciiDigits.length - 3);
    final tail = asciiDigits.substring(asciiDigits.length - 3);
    final groupSize = bangladeshiGrouping ? 2 : 3;
    final parts = <String>[];
    for (var end = head.length; end > 0; end -= groupSize) {
      final start = end - groupSize < 0 ? 0 : end - groupSize;
      parts.insert(0, head.substring(start, end));
    }
    return '${parts.join(',')},$tail';
  }

  /// Renders already-formatted ASCII text using the configured digit style.
  String localize(String ascii) =>
      style == DigitStyle.bangla ? toBangla(ascii) : ascii;

  /// Groups and localizes a non-negative integer.
  String formatInt(int value) {
    final sign = value < 0 ? '-' : '';
    return '$sign${localize(group(value.abs().toString()))}';
  }
}
