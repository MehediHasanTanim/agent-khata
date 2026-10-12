import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/ledger/posting_strategy.dart';
import '../../core/ledger/transaction_draft.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import '../commission/commission_engine.dart';
import '../transactions/entry_guards.dart';
import '../transactions/transaction_repository.dart';
import 'amount_entry.dart';
import 'amount_keypad.dart';
import 'entry_providers.dart';

enum EntryKind {
  cashOut(TransactionType.cashOut),
  cashIn(TransactionType.cashIn),
  floatPurchase(TransactionType.floatPurchase),
  expense(TransactionType.expense);

  const EntryKind(this.type);
  final TransactionType type;
}

/// Single-screen entry: pick account, type amount, save. Pops with the new
/// transaction id so the caller can offer "Undo".
class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key, required this.kind});

  final EntryKind kind;

  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  static const _lastWalletKey = 'last_wallet_id';
  static const _engine = CommissionEngine();

  AmountEntry _entry = const AmountEntry();
  String? _walletId;
  String? _sourceId;
  String? _categoryId;
  bool _saving = false;
  final _customer = TextEditingController();
  final _note = TextEditingController();
  final _trxId = TextEditingController();

  @override
  void dispose() {
    _customer.dispose();
    _note.dispose();
    _trxId.dispose();
    super.dispose();
  }

  String _title(AppLocalizations l10n) => switch (widget.kind) {
    EntryKind.cashOut => l10n.txnCashOut,
    EntryKind.cashIn => l10n.txnCashIn,
    EntryKind.floatPurchase => l10n.txnFloatPurchase,
    EntryKind.expense => l10n.txnExpense,
  };

  List<Account> _wallets(List<Account> all) => [
    for (final a in all)
      if (a.kind == AccountKind.wallet ||
          (widget.kind == EntryKind.floatPurchase &&
              a.kind == AccountKind.load))
        a,
  ];

  Account? _first(List<Account> all, AccountKind kind) {
    for (final a in all) {
      if (a.kind == kind) return a;
    }
    return null;
  }

  Account? _byId(List<Account> list, String? id) {
    for (final a in list) {
      if (a.id == id) return a;
    }
    return null;
  }

  Account? _selectedWallet(List<Account> wallets) {
    final byId = _byId(wallets, _walletId);
    if (byId != null) return byId;
    final remembered = ref
        .read(sharedPreferencesProvider)
        .getString(_lastWalletKey);
    return _byId(wallets, remembered) ??
        (wallets.isEmpty ? null : wallets.first);
  }

  /// The account money leaves, and the one it arrives in.
  ({Account? from, Account? to}) _legs({
    required List<Account> accounts,
    required Account? wallet,
    required Account? source,
    required Account? category,
  }) {
    final cash = _first(accounts, AccountKind.cash);
    return switch (widget.kind) {
      EntryKind.cashOut => (from: cash, to: wallet),
      EntryKind.cashIn => (from: wallet, to: cash),
      EntryKind.floatPurchase => (from: source ?? cash, to: wallet),
      EntryKind.expense => (from: cash, to: category),
    };
  }

  Future<void> _save({
    required List<Account> accounts,
    required Account from,
    required Account to,
    required Account? wallet,
    required Money commission,
    required String? ruleId,
  }) async {
    final l10n = AppLocalizations.of(context);
    final money = MoneyFormatter(digits: ref.read(preferencesProvider).digits);
    final prefs = ref.read(preferencesProvider);
    final now = DateTime.now().toUtc();
    final balances = ref.read(balancesProvider).value ?? const {};
    final customer = _customer.text.trim().isEmpty
        ? null
        : _customer.text.trim();

    final duplicate = await ref
        .read(transactionQueriesProvider)
        .hasDuplicate(
          type: widget.kind.type,
          amount: _entry.amount,
          accountId: (wallet ?? to).id,
          now: now,
          customerNumber: customer,
        );
    final checks = evaluateEntry(
      amount: _entry.amount,
      sourceBalance: balances[from.id] ?? Money.zero,
      largeThreshold: Money.taka(prefs.largeAmountTaka),
      duplicateFound: duplicate,
    );
    if (!mounted) return;

    if (checks.needsConfirmation) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            checks.isDuplicate ? l10n.warnDuplicateTitle : l10n.warnLargeTitle,
          ),
          content: Text(
            checks.isDuplicate
                ? l10n.warnDuplicateBody
                : l10n.warnLargeBody(money.format(_entry.amount)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.saveAnyway),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }

    setState(() => _saving = true);
    try {
      final id = await ref
          .read(transactionRepositoryProvider)
          .post(
            TransactionDraft(
              type: widget.kind.type,
              occurredAt: now,
              amount: _entry.amount,
              fromAccountId: from.id,
              toAccountId: to.id,
              commission: commission,
              commissionRuleId: ruleId,
              customerNumber: customer,
              reference: _trxId.text.trim().isEmpty ? null : _trxId.text.trim(),
              note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            ),
          );
      if (wallet != null) {
        await ref
            .read(sharedPreferencesProvider)
            .setString(_lastWalletKey, wallet.id);
      }
      await HapticFeedback.mediumImpact();
      if (mounted) Navigator.of(context).pop(id);
    } on PostingException {
      _failed(l10n);
    } on DayLockedException {
      _failed(l10n);
    }
  }

  void _failed(AppLocalizations l10n) {
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.entrySaveFailed)));
  }

  Future<void> _addCategory() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.entryNewCategory),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.entryCategoryName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    final id = await ref
        .read(accountRepositoryProvider)
        .create(kind: AccountKind.expense, label: name);
    if (mounted) setState(() => _categoryId = id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final prefs = ref.watch(preferencesProvider);
    final digits = prefs.digits;
    final money = MoneyFormatter(digits: digits);

    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final balances = ref.watch(balancesProvider).value ?? const {};
    final rules = ref.watch(commissionRulesProvider).value ?? const [];
    final categories = ref.watch(expenseAccountsProvider).value ?? const [];
    final quick = ref.watch(quickAmountsProvider(widget.kind.type)).value;
    final lastAmount = quick?.last;

    final wallets = _wallets(accounts);
    final wallet = _selectedWallet(wallets);
    final sources = [
      for (final a in accounts)
        if (a.kind == AccountKind.cash || a.kind == AccountKind.bank) a,
    ];
    final source = _byId(sources, _sourceId);
    final category =
        _byId(categories, _categoryId) ??
        (categories.isEmpty ? null : categories.first);

    final needsWallet = widget.kind != EntryKind.expense;
    final legs = _legs(
      accounts: accounts,
      wallet: wallet,
      source: source,
      category: category,
    );

    var commission = Money.zero;
    String? ruleId;
    final earnsCommission =
        widget.kind == EntryKind.cashOut || widget.kind == EntryKind.cashIn;
    if (earnsCommission &&
        wallet?.provider != null &&
        _entry.amount.isPositive) {
      final res = _engine.compute(
        rules: rules,
        provider: wallet!.provider!,
        type: widget.kind.type,
        amount: _entry.amount,
        at: DateTime.now().toUtc(),
      );
      commission = res.amount;
      ruleId = res.ruleId;
    }

    final from = legs.from;
    final to = legs.to;
    final negative =
        from != null &&
        _entry.amount.isPositive &&
        (balances[from.id] ?? Money.zero) - _entry.amount < Money.zero;
    final canSave =
        _entry.amount.isPositive && from != null && to != null && !_saving;

    final direction = widget.kind == EntryKind.cashIn
        ? tokens.cashIn
        : widget.kind == EntryKind.cashOut
        ? tokens.cashOut
        : theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(_title(l10n))),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                children: [
                  if (needsWallet) ...[
                    if (wallets.isEmpty)
                      Text(l10n.entryNoWallet)
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final w in wallets)
                            ChoiceChip(
                              key: ValueKey('wallet-${w.id}'),
                              label: Text(w.label),
                              selected: w.id == wallet?.id,
                              onSelected: (_) =>
                                  setState(() => _walletId = w.id),
                            ),
                        ],
                      ),
                  ] else ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final c in categories)
                          ChoiceChip(
                            key: ValueKey('category-${c.id}'),
                            label: Text(c.label),
                            selected: c.id == category?.id,
                            onSelected: (_) =>
                                setState(() => _categoryId = c.id),
                          ),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 18),
                          label: Text(l10n.entryNewCategory),
                          onPressed: _addCategory,
                        ),
                      ],
                    ),
                  ],
                  if (widget.kind == EntryKind.floatPurchase &&
                      sources.length > 1) ...[
                    const SizedBox(height: 8),
                    Text(l10n.entryPaidFrom, style: theme.textTheme.labelLarge),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final s in sources)
                          ChoiceChip(
                            label: Text(s.label),
                            selected: s.id == (source ?? sources.first).id,
                            onSelected: (_) => setState(() => _sourceId = s.id),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Center(
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        money.format(_entry.amount),
                        key: const ValueKey('amount-display'),
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: direction,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      earnsCommission && _entry.amount.isPositive
                          ? l10n.entryCommission(money.format(commission))
                          : ' ',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  if (negative)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber, color: tokens.warning),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.warnNegative(from.label),
                              style: TextStyle(color: tokens.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (lastAmount != null)
                    Align(
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _entry = _entry.set(lastAmount)),
                        child: Text(
                          l10n.entryRepeatLast(money.format(lastAmount)),
                        ),
                      ),
                    ),
                  ExpansionTile(
                    title: Text(l10n.entryMoreDetails),
                    tilePadding: EdgeInsets.zero,
                    children: [
                      TextField(
                        controller: _customer,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.entryCustomerNumber,
                        ),
                      ),
                      TextField(
                        controller: _trxId,
                        decoration: InputDecoration(labelText: l10n.entryTrxId),
                      ),
                      TextField(
                        controller: _note,
                        decoration: InputDecoration(labelText: l10n.entryNote),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AmountKeypad(
              digits: digits,
              chips: quick?.chips ?? const [],
              onKey: (k) => setState(() => _entry = _entry.press(k)),
              onBackspace: () => setState(() => _entry = _entry.backspace()),
              onChip: (m) => setState(() => _entry = _entry.set(m)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  key: const ValueKey('save-button'),
                  onPressed: canSave
                      ? () => _save(
                          accounts: accounts,
                          from: from,
                          to: to,
                          wallet: needsWallet ? wallet : null,
                          commission: commission,
                          ruleId: ruleId,
                        )
                      : null,
                  child: Text(
                    l10n.save,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
