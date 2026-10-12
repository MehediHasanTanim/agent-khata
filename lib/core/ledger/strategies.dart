import 'account.dart';
import 'account_kind.dart';
import 'ledger_entry_draft.dart';
import 'posting_strategy.dart';
import 'transaction_draft.dart';
import 'transaction_type.dart';

const _walletOnly = {AccountKind.wallet};
const _cashOnly = {AccountKind.cash};
const _cashOrBank = {AccountKind.cash, AccountKind.bank};

/// `from` -= amount; `to` += amount (+ charge, with the charge sourced from
/// the external account). Shared by cash-in, send-money and bill-pay: the
/// customer hands cash over and the agent's wallet pays out.
abstract class _WalletToCashStrategy extends PostingStrategy
    with PostingChecks {
  const _WalletToCashStrategy();

  @override
  void validate(TransactionDraft d, AccountResolver accounts) {
    requireBasics(d, allowCharge: true);
    requireAccount(d.fromAccountId, accounts, _walletOnly, 'from');
    requireAccount(d.toAccountId, accounts, _cashOnly, 'to');
  }

  @override
  List<LedgerEntryDraft> post(TransactionDraft d, AccountResolver accounts) {
    validate(d, accounts);
    final entries = [
      LedgerEntryDraft(
        accountId: d.fromAccountId!,
        deltaPaisa: -d.amount.paisa,
      ),
      LedgerEntryDraft(
        accountId: d.toAccountId!,
        deltaPaisa: d.amount.paisa + d.charge.paisa,
      ),
      if (!d.charge.isZero)
        LedgerEntryDraft(
          accountId: accounts.externalAccountId,
          deltaPaisa: -d.charge.paisa,
        ),
    ];
    assertBalanced(entries);
    return entries;
  }
}

class CashInStrategy extends _WalletToCashStrategy {
  const CashInStrategy();
  @override
  TransactionType get type => TransactionType.cashIn;
}

class SendMoneyStrategy extends _WalletToCashStrategy {
  const SendMoneyStrategy();
  @override
  TransactionType get type => TransactionType.sendMoney;
}

class BillPayStrategy extends _WalletToCashStrategy {
  const BillPayStrategy();
  @override
  TransactionType get type => TransactionType.billPay;
}

/// Customer withdraws: cash drawer pays out, wallet float rises. Commission
/// is credited by the provider later, so it is recorded on the transaction
/// but not posted.
class CashOutStrategy extends PostingStrategy with PostingChecks {
  const CashOutStrategy();

  @override
  TransactionType get type => TransactionType.cashOut;

  @override
  void validate(TransactionDraft d, AccountResolver accounts) {
    requireBasics(d);
    requireAccount(d.fromAccountId, accounts, _cashOnly, 'from');
    requireAccount(d.toAccountId, accounts, _walletOnly, 'to');
  }

  @override
  List<LedgerEntryDraft> post(TransactionDraft d, AccountResolver accounts) {
    validate(d, accounts);
    final entries = [
      LedgerEntryDraft(
        accountId: d.fromAccountId!,
        deltaPaisa: -d.amount.paisa,
      ),
      LedgerEntryDraft(accountId: d.toAccountId!, deltaPaisa: d.amount.paisa),
    ];
    assertBalanced(entries);
    return entries;
  }
}

/// Top-up sold for cash. `amount` is the price charged to the customer.
/// The load balance falls by the cost (`amount - commission`); the margin
/// (`commission`) is posted against the external account.
class FlexiloadStrategy extends PostingStrategy with PostingChecks {
  const FlexiloadStrategy();

  @override
  TransactionType get type => TransactionType.flexiload;

  @override
  void validate(TransactionDraft d, AccountResolver accounts) {
    requireBasics(d);
    if (d.commission > d.amount) {
      throw const PostingException(
        'margin_exceeds_price',
        'Margin cannot exceed the price charged',
      );
    }
    requireAccount(d.fromAccountId, accounts, {AccountKind.load}, 'from');
    requireAccount(d.toAccountId, accounts, _cashOnly, 'to');
  }

  @override
  List<LedgerEntryDraft> post(TransactionDraft d, AccountResolver accounts) {
    validate(d, accounts);
    final cost = d.amount - d.commission;
    final entries = [
      LedgerEntryDraft(accountId: d.fromAccountId!, deltaPaisa: -cost.paisa),
      LedgerEntryDraft(accountId: d.toAccountId!, deltaPaisa: d.amount.paisa),
      if (!d.commission.isZero)
        LedgerEntryDraft(
          accountId: accounts.externalAccountId,
          deltaPaisa: -d.commission.paisa,
        ),
    ];
    assertBalanced(entries);
    return entries;
  }
}

/// Plain one-for-one move from `from` to `to`.
abstract class _MoveStrategy extends PostingStrategy with PostingChecks {
  const _MoveStrategy();

  Set<AccountKind> get fromKinds;
  Set<AccountKind> get toKinds;
  bool get allowCharge => false;

  @override
  void validate(TransactionDraft d, AccountResolver accounts) {
    requireBasics(d, allowCharge: allowCharge);
    requireDistinct(d);
    final from = requireAccount(d.fromAccountId, accounts, fromKinds, 'from');
    final to = requireAccount(d.toAccountId, accounts, toKinds, 'to');
    extraChecks(from, to);
  }

  void extraChecks(Account from, Account to) {}

  @override
  List<LedgerEntryDraft> post(TransactionDraft d, AccountResolver accounts) {
    validate(d, accounts);
    final entries = [
      LedgerEntryDraft(
        accountId: d.fromAccountId!,
        deltaPaisa: -(d.amount.paisa + d.charge.paisa),
      ),
      LedgerEntryDraft(accountId: d.toAccountId!, deltaPaisa: d.amount.paisa),
      if (!d.charge.isZero)
        LedgerEntryDraft(
          accountId: accounts.externalAccountId,
          deltaPaisa: d.charge.paisa,
        ),
    ];
    assertBalanced(entries);
    return entries;
  }
}

/// Buying e-float (or load stock) with cash or from the bank.
class FloatPurchaseStrategy extends _MoveStrategy {
  const FloatPurchaseStrategy();
  @override
  TransactionType get type => TransactionType.floatPurchase;
  @override
  Set<AccountKind> get fromKinds => _cashOrBank;
  @override
  Set<AccountKind> get toKinds => {AccountKind.wallet, AccountKind.load};
}

/// Wallet-to-wallet float transfer; the fee (if any) leaves the source.
class FloatTransferStrategy extends _MoveStrategy {
  const FloatTransferStrategy();
  @override
  TransactionType get type => TransactionType.floatTransfer;
  @override
  Set<AccountKind> get fromKinds => _walletOnly;
  @override
  Set<AccountKind> get toKinds => _walletOnly;
  @override
  bool get allowCharge => true;
}

/// Cash to bank (deposit) or bank to cash (withdrawal).
class BankDepositStrategy extends _MoveStrategy {
  const BankDepositStrategy();
  @override
  TransactionType get type => TransactionType.bankDeposit;
  @override
  Set<AccountKind> get fromKinds => _cashOrBank;
  @override
  Set<AccountKind> get toKinds => _cashOrBank;

  @override
  void extraChecks(Account from, Account to) {
    if (from.kind == to.kind) {
      throw const PostingException(
        'same_kind',
        'Bank deposit moves between cash and bank',
      );
    }
  }
}

/// Spending cash (or bank) on an expense category account.
class ExpenseStrategy extends _MoveStrategy {
  const ExpenseStrategy();
  @override
  TransactionType get type => TransactionType.expense;
  @override
  Set<AccountKind> get fromKinds => _cashOrBank;
  @override
  Set<AccountKind> get toKinds => {AccountKind.expense};
}

/// Manual correction. Exactly one of from/to is set; the other side is the
/// external account. `to` set raises that account; `from` set lowers it.
class AdjustmentStrategy extends PostingStrategy with PostingChecks {
  const AdjustmentStrategy();

  @override
  TransactionType get type => TransactionType.adjustment;

  @override
  void validate(TransactionDraft d, AccountResolver accounts) {
    requireBasics(d);
    if ((d.fromAccountId == null) == (d.toAccountId == null)) {
      throw const PostingException(
        'adjustment_one_side',
        'Adjustment must set exactly one of from/to account',
      );
    }
    if (d.note == null || d.note!.trim().isEmpty) {
      throw const PostingException(
        'reason_required',
        'Adjustment requires a reason',
      );
    }
    requireAccount(
      d.fromAccountId ?? d.toAccountId,
      accounts,
      countedKinds,
      'target',
    );
  }

  @override
  List<LedgerEntryDraft> post(TransactionDraft d, AccountResolver accounts) {
    validate(d, accounts);
    final increase = d.toAccountId != null;
    final target = (increase ? d.toAccountId : d.fromAccountId)!;
    final delta = increase ? d.amount.paisa : -d.amount.paisa;
    final entries = [
      LedgerEntryDraft(accountId: target, deltaPaisa: delta),
      LedgerEntryDraft(
        accountId: accounts.externalAccountId,
        deltaPaisa: -delta,
      ),
    ];
    assertBalanced(entries);
    return entries;
  }
}

/// Maps each [TransactionType] to its strategy.
class PostingRegistry {
  PostingRegistry(Iterable<PostingStrategy> strategies)
    : _byType = {for (final s in strategies) s.type: s};

  factory PostingRegistry.standard() => PostingRegistry(const [
    CashInStrategy(),
    CashOutStrategy(),
    SendMoneyStrategy(),
    BillPayStrategy(),
    FlexiloadStrategy(),
    FloatPurchaseStrategy(),
    FloatTransferStrategy(),
    BankDepositStrategy(),
    ExpenseStrategy(),
    AdjustmentStrategy(),
  ]);

  final Map<TransactionType, PostingStrategy> _byType;

  PostingStrategy strategyFor(TransactionType type) {
    final s = _byType[type];
    if (s == null) {
      throw StateError('No posting strategy registered for ${type.name}');
    }
    return s;
  }
}
