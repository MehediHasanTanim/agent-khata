import '../../core/money/money.dart';

/// Non-blocking warnings shown while entering a transaction.
class EntryChecks {
  const EntryChecks({
    required this.sourceGoesNegative,
    required this.isLarge,
    required this.isDuplicate,
  });

  /// The account money leaves would drop below zero.
  final bool sourceGoesNegative;

  /// At or above the user's large-amount threshold.
  final bool isLarge;

  /// Same type, amount, account and customer was saved moments ago.
  final bool isDuplicate;

  /// Warnings that deserve an explicit "save anyway".
  bool get needsConfirmation => isLarge || isDuplicate;

  bool get hasAny => sourceGoesNegative || isLarge || isDuplicate;
}

EntryChecks evaluateEntry({
  required Money amount,
  required Money sourceBalance,
  required Money largeThreshold,
  required bool duplicateFound,
}) => EntryChecks(
  sourceGoesNegative: amount.isPositive && sourceBalance - amount < Money.zero,
  isLarge: amount >= largeThreshold,
  isDuplicate: duplicateFound,
);
