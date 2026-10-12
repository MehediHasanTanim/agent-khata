import '../money/money.dart';
import 'transaction_type.dart';

/// Everything the UI collects for one business event, before posting.
///
/// Sign convention for [fromAccountId] / [toAccountId]: money leaves
/// `from` (its balance falls) and arrives in `to` (its balance rises).
/// So a cash-out has from = cash drawer, to = wallet.
class TransactionDraft {
  const TransactionDraft({
    required this.type,
    required this.occurredAt,
    required this.amount,
    this.fromAccountId,
    this.toAccountId,
    this.charge = Money.zero,
    this.commission = Money.zero,
    this.commissionRuleId,
    this.commissionOverridden = false,
    this.customerId,
    this.customerNumber,
    this.reference,
    this.note,
    this.createdBy = 'owner',
    this.shiftId,
  });

  final TransactionType type;
  final DateTime occurredAt;

  /// Principal amount; always > 0. Direction is expressed by from/to.
  final Money amount;
  final String? fromAccountId;
  final String? toAccountId;

  /// Fee collected from (or paid by) the agent on top of [amount].
  final Money charge;

  /// Provider commission or flexiload margin, as computed by the commission
  /// engine (or manually overridden).
  final Money commission;
  final String? commissionRuleId;
  final bool commissionOverridden;

  final String? customerId;
  final String? customerNumber;
  final String? reference;
  final String? note;
  final String createdBy;
  final String? shiftId;
}
