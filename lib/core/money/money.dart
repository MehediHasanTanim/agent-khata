/// An amount of Bangladeshi taka stored as integer paisa (1 taka = 100 paisa).
///
/// Never uses floating point. All arithmetic is exact; ratios round half-up
/// (away from zero for negatives) via [mulRatio].
class Money implements Comparable<Money> {
  const Money.paisa(this.paisa);

  /// Whole taka.
  const Money.taka(int taka) : paisa = taka * 100;

  static const zero = Money.paisa(0);

  final int paisa;

  bool get isZero => paisa == 0;
  bool get isNegative => paisa < 0;
  bool get isPositive => paisa > 0;
  bool get hasPaisa => paisa % 100 != 0;

  /// Whole taka portion, truncated toward zero.
  int get wholeTaka => paisa ~/ 100;

  /// Paisa portion (0-99), always non-negative.
  int get paisaPart => paisa.abs() % 100;

  Money operator +(Money other) => Money.paisa(paisa + other.paisa);
  Money operator -(Money other) => Money.paisa(paisa - other.paisa);
  Money operator -() => Money.paisa(-paisa);
  Money operator *(int factor) => Money.paisa(paisa * factor);

  Money abs() => Money.paisa(paisa.abs());

  /// Returns `this * numerator / denominator`, rounded half-up to the nearest
  /// paisa (ties away from zero). Used by the commission engine, e.g.
  /// per-thousand rates and basis-point percentages.
  Money mulRatio(int numerator, int denominator) {
    if (denominator == 0) {
      throw ArgumentError.value(denominator, 'denominator', 'must not be 0');
    }
    var n = paisa * numerator;
    var d = denominator;
    if (d < 0) {
      n = -n;
      d = -d;
    }
    final negative = n < 0;
    final absN = n.abs();
    final rounded = (absN * 2 + d) ~/ (d * 2);
    return Money.paisa(negative ? -rounded : rounded);
  }

  /// Parses ASCII text such as `1500`, `1500.5`, `1500.50` (no grouping).
  /// Returns `null` when [input] is not a valid non-negative amount.
  static Money? tryParse(String input) {
    final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(input.trim());
    if (match == null) return null;
    final taka = int.parse(match.group(1)!);
    final fraction = (match.group(2) ?? '').padRight(2, '0');
    return Money.paisa(
      taka * 100 + int.parse(fraction.isEmpty ? '0' : fraction),
    );
  }

  @override
  int compareTo(Money other) => paisa.compareTo(other.paisa);

  bool operator <(Money other) => paisa < other.paisa;
  bool operator <=(Money other) => paisa <= other.paisa;
  bool operator >(Money other) => paisa > other.paisa;
  bool operator >=(Money other) => paisa >= other.paisa;

  @override
  bool operator ==(Object other) => other is Money && other.paisa == paisa;

  @override
  int get hashCode => paisa.hashCode;

  @override
  String toString() => 'Money($paisa paisa)';
}
