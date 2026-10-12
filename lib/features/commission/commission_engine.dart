import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import 'commission_rule.dart';

/// Result of a commission lookup. [ruleId] is the snapshot stored on the
/// transaction so later rate edits never change history.
class CommissionResult {
  const CommissionResult({
    required this.amount,
    this.ruleId,
    this.overridden = false,
  });

  final Money amount;
  final String? ruleId;
  final bool overridden;

  static const none = CommissionResult(amount: Money.zero);
}

/// Pure commission calculation with integer math and half-up rounding.
class CommissionEngine {
  const CommissionEngine();

  /// The rule for [provider] and [type] in effect at [at]. If several match,
  /// the one with the latest `effectiveFrom` wins (ties: greatest id).
  CommissionRule? selectRule(
    Iterable<CommissionRule> rules, {
    required String provider,
    required TransactionType type,
    required DateTime at,
  }) {
    CommissionRule? best;
    for (final r in rules) {
      if (r.provider != provider || r.txnType != type || !r.isEffectiveAt(at)) {
        continue;
      }
      if (best == null) {
        best = r;
        continue;
      }
      final cmp = r.effectiveFrom.compareTo(best.effectiveFrom);
      if (cmp > 0 || (cmp == 0 && r.id.compareTo(best.id) > 0)) best = r;
    }
    return best;
  }

  Money apply(CommissionRule rule, Money amount) => switch (rule.mode) {
    CommissionMode.perThousand => amount.mulRatio(rule.value, 100000),
    CommissionMode.percent => amount.mulRatio(rule.value, 10000),
    CommissionMode.fixed => Money.paisa(rule.value),
  };

  /// Computes commission for a transaction. A non-null [override] wins and
  /// is flagged `overridden`. With no matching rule the result is zero.
  CommissionResult compute({
    required Iterable<CommissionRule> rules,
    required String provider,
    required TransactionType type,
    required Money amount,
    required DateTime at,
    Money? override,
  }) {
    final rule = selectRule(rules, provider: provider, type: type, at: at);
    if (override != null) {
      return CommissionResult(
        amount: override,
        ruleId: rule?.id,
        overridden: true,
      );
    }
    if (rule == null) return CommissionResult.none;
    return CommissionResult(amount: apply(rule, amount), ruleId: rule.id);
  }
}
