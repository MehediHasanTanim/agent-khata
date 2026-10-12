import '../i18n/digit_formatter.dart';
import 'money.dart';

/// How paisa is shown.
enum PaisaDisplay {
  /// Show paisa only when the amount has a non-zero paisa part.
  auto,
  always,
  never,
}

/// Formats [Money] for display: `৳ ১,২৩,৪৫৬` or `৳ 123,456.50`.
class MoneyFormatter {
  const MoneyFormatter({
    this.digits = const DigitFormatter(),
    this.paisaDisplay = PaisaDisplay.auto,
    this.showSymbol = true,
  });

  static const symbol = '৳';

  final DigitFormatter digits;
  final PaisaDisplay paisaDisplay;
  final bool showSymbol;

  String format(Money money) {
    final showPaisa = switch (paisaDisplay) {
      PaisaDisplay.always => true,
      PaisaDisplay.never => false,
      PaisaDisplay.auto => money.hasPaisa,
    };
    final whole = (money.paisa.abs() ~/ 100).toString();
    var text = digits.group(whole);
    if (showPaisa) {
      text = '$text.${money.paisaPart.toString().padLeft(2, '0')}';
    }
    text = digits.localize(text);
    final sign = money.isNegative ? '-' : '';
    return showSymbol ? '$sign$symbol $text' : '$sign$text';
  }
}
