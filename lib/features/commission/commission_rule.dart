import '../../core/ledger/transaction_type.dart';

enum CommissionMode {
  /// `value` = paisa earned per ৳1,000 of amount.
  perThousand('per_thousand'),

  /// `value` = basis points (100 = 1%).
  percent('percent'),

  /// `value` = flat paisa per transaction.
  fixed('fixed');

  const CommissionMode(this.dbName);
  final String dbName;

  static CommissionMode fromDb(String v) =>
      CommissionMode.values.firstWhere((m) => m.dbName == v);
}

/// A user-configured, effective-dated commission (or margin) rule.
class CommissionRule {
  const CommissionRule({
    required this.id,
    required this.provider,
    required this.txnType,
    required this.mode,
    required this.value,
    required this.effectiveFrom,
    this.effectiveTo,
  });

  final String id;

  /// `bkash`, `nagad`, `gp`, ...
  final String provider;
  final TransactionType txnType;
  final CommissionMode mode;
  final int value;

  /// Inclusive.
  final DateTime effectiveFrom;

  /// Exclusive; null = open-ended.
  final DateTime? effectiveTo;

  bool isEffectiveAt(DateTime at) =>
      !at.isBefore(effectiveFrom) &&
      (effectiveTo == null || at.isBefore(effectiveTo!));
}
