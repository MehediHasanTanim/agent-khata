import '../../core/money/money.dart';

/// Default chips shown until the app has learned the user's habits.
const defaultQuickAmounts = [
  Money.taka(500),
  Money.taka(1000),
  Money.taka(2000),
  Money.taka(5000),
];

/// Merges learned (most frequent first) amounts with [defaults] into at most
/// [count] unique chips, learned ones first.
List<Money> mergeQuickAmounts(
  List<Money> learned, {
  List<Money> defaults = defaultQuickAmounts,
  int count = 4,
}) {
  final out = <Money>[];
  for (final m in [...learned, ...defaults]) {
    if (!m.isPositive || out.contains(m)) continue;
    out.add(m);
    if (out.length == count) break;
  }
  return out;
}
