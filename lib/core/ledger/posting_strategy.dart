import 'account.dart';
import 'account_kind.dart';
import 'ledger_entry_draft.dart';
import 'transaction_draft.dart';
import 'transaction_type.dart';

/// Thrown when a draft cannot be posted. [code] is stable for UI mapping.
class PostingException implements Exception {
  const PostingException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'PostingException($code): $message';
}

/// Turns a [TransactionDraft] into balanced ledger entries.
///
/// Every strategy posts entries whose deltas sum to zero, counting the
/// hidden external and expense accounts, so the books always balance.
abstract class PostingStrategy {
  const PostingStrategy();

  TransactionType get type;

  /// Throws [PostingException] if [draft] is not postable.
  void validate(TransactionDraft draft, AccountResolver accounts);

  /// Validates, then returns the entries (sum of deltas is 0).
  List<LedgerEntryDraft> post(TransactionDraft draft, AccountResolver accounts);
}

/// Shared validation helpers for strategies.
mixin PostingChecks {
  void requireBasics(TransactionDraft d, {bool allowCharge = false}) {
    if (!d.amount.isPositive) {
      throw const PostingException('amount_not_positive', 'Amount must be > 0');
    }
    if (d.charge.isNegative) {
      throw const PostingException('charge_negative', 'Charge must be >= 0');
    }
    if (!allowCharge && !d.charge.isZero) {
      throw const PostingException(
        'charge_not_allowed',
        'This transaction type does not take a charge',
      );
    }
    if (d.commission.isNegative) {
      throw const PostingException(
        'commission_negative',
        'Commission must be >= 0',
      );
    }
  }

  Account requireAccount(
    String? id,
    AccountResolver accounts,
    Set<AccountKind> kinds,
    String role,
  ) {
    if (id == null) {
      throw PostingException('missing_$role', 'Missing $role account');
    }
    final account = accounts.find(id);
    if (account == null) {
      throw PostingException('unknown_$role', 'Unknown $role account: $id');
    }
    if (!account.isActive) {
      throw PostingException('inactive_$role', 'Inactive $role account');
    }
    if (!kinds.contains(account.kind)) {
      throw PostingException(
        'wrong_kind_$role',
        '$role account must be one of ${kinds.map((k) => k.name).join('/')}, '
            'got ${account.kind.name}',
      );
    }
    return account;
  }

  void requireDistinct(TransactionDraft d) {
    if (d.fromAccountId == d.toAccountId) {
      throw const PostingException(
        'same_account',
        'From and to accounts must differ',
      );
    }
  }
}

/// Throws if [entries] do not sum to zero.
void assertBalanced(List<LedgerEntryDraft> entries) {
  final sum = entries.fold<int>(0, (acc, e) => acc + e.deltaPaisa);
  if (sum != 0) {
    throw PostingException('unbalanced', 'Entries sum to $sum paisa, not 0');
  }
}
