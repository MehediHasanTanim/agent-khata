import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/digit_formatter.dart';
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
import '../customers/customer_repository.dart';
import '../transactions/entry_guards.dart';
import '../transactions/transaction_repository.dart';
import 'amount_entry.dart';
import 'amount_keypad.dart';
import 'entry_providers.dart';

enum EntryKind {
  cashOut(TransactionType.cashOut),
  cashIn(TransactionType.cashIn),
  flexiload(TransactionType.flexiload),
  floatPurchase(TransactionType.floatPurchase),
  expense(TransactionType.expense);

  const EntryKind(this.type);
  final TransactionType type;
}

/// Values of an existing entry, used to prefill the screen when editing.
class EditSeed {
  const EditSeed({
    required this.txnId,
    required this.amount,
    required this.occurredAt,
    this.fromAccountId,
    this.toAccountId,
    this.customerNumber,
    this.reference,
    this.note,
    this.paidPaisa = 0,
  });

  final String txnId;
  final Money amount;
  final DateTime occurredAt;
  final String? fromAccountId;
  final String? toAccountId;
  final String? customerNumber;
  final String? reference;
  final String? note;

  /// What left the source account (float purchases).
  final int paidPaisa;
}

/// Single-screen entry: pick account, type amount, save. Pops with the new
/// transaction id so the caller can offer "Undo".
class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key, required this.kind, this.edit});

  final EntryKind kind;

  /// When set, saving replaces this entry instead of creating a new one.
  final EditSeed? edit;

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
  final _customerName = TextEditingController();
  final _customerFocus = FocusNode();
  final _note = TextEditingController();
  final _trxId = TextEditingController();
  final _paid = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    if (e == null) return;
    _entry = const AmountEntry().set(e.amount);
    _customer.text = e.customerNumber ?? '';
    _trxId.text = e.reference ?? '';
    _note.text = e.note ?? '';
    switch (widget.kind) {
      case EntryKind.cashOut:
        _walletId = e.toAccountId;
      case EntryKind.cashIn:
      case EntryKind.flexiload:
        _walletId = e.fromAccountId;
      case EntryKind.floatPurchase:
        _walletId = e.toAccountId;
        _sourceId = e.fromAccountId;
        if (e.paidPaisa != 0 && e.paidPaisa != e.amount.paisa) {
          _paid.text = Money.paisa(e.paidPaisa).hasPaisa
              ? '${e.paidPaisa ~/ 100}.${(e.paidPaisa % 100).toString().padLeft(2, '0')}'
              : '${e.paidPaisa ~/ 100}';
        }
      case EntryKind.expense:
        _categoryId = e.toAccountId;
    }
  }

  @override
  void dispose() {
    _customer.dispose();
    _customerName.dispose();
    _customerFocus.dispose();
    _note.dispose();
    _trxId.dispose();
    _paid.dispose();
    super.dispose();
  }

  String _title(AppLocalizations l10n) => widget.edit != null
      ? l10n.entryEditTitle
      : switch (widget.kind) {
          EntryKind.cashOut => l10n.txnCashOut,
          EntryKind.cashIn => l10n.txnCashIn,
          EntryKind.flexiload => l10n.txnFlexiload,
          EntryKind.floatPurchase => l10n.txnFloatPurchase,
          EntryKind.expense => l10n.txnExpense,
        };

  List<Account> _wallets(List<Account> all) => [
    for (final a in all)
      if (switch (widget.kind) {
        EntryKind.flexiload => a.kind == AccountKind.load,
        EntryKind.floatPurchase =>
          a.kind == AccountKind.wallet || a.kind == AccountKind.load,
        _ => a.kind == AccountKind.wallet,
      })
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
      EntryKind.flexiload => (from: wallet, to: cash),
      EntryKind.floatPurchase => (from: source ?? cash, to: wallet),
      EntryKind.expense => (from: cash, to: category),
    };
  }

  Future<void> _save({
    required Account from,
    required Account to,
    required Account? wallet,
    required Money commission,
    required String? ruleId,
    required Money sourceOutflow,
    required Money charge,
    required Money discount,
  }) async {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.read(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final edit = widget.edit;
    final now = DateTime.now().toUtc();
    final balances = ref.read(balancesProvider).value ?? const {};
    final customer = _customer.text.trim().isEmpty
        ? null
        : DigitFormatter.toLatin(_customer.text.trim());

    final duplicate = edit != null
        ? false
        : await ref
              .read(transactionQueriesProvider)
              .hasDuplicate(
                type: widget.kind.type,
                amount: _entry.amount,
                accountId: (wallet ?? to).id,
                now: now,
                customerNumber: customer,
              );
    final checks = evaluateEntry(
      amount: sourceOutflow,
      sourceBalance: balances[from.id] ?? Money.zero,
      largeThreshold: Money.taka(prefs.largeAmountTaka),
      duplicateFound: duplicate,
    );
    if (!mounted) return;

    if (checks.needsConfirmation && edit == null) {
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
      String? customerId;
      if (prefs.rememberCustomers && customer != null) {
        customerId = await ref
            .read(customerRepositoryProvider)
            .upsert(phone: customer, name: _customerName.text);
      }
      final draft = TransactionDraft(
        type: widget.kind.type,
        occurredAt: edit?.occurredAt ?? now,
        amount: _entry.amount,
        fromAccountId: from.id,
        toAccountId: to.id,
        charge: charge,
        discount: discount,
        commission: commission,
        commissionRuleId: ruleId,
        customerId: customerId,
        customerNumber: customer,
        reference: _trxId.text.trim().isEmpty ? null : _trxId.text.trim(),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      final repo = ref.read(transactionRepositoryProvider);
      final id = edit == null
          ? await repo.post(draft)
          : await repo.edit(edit.txnId, draft, userId: 'owner');
      if (wallet != null) {
        await ref
            .read(sharedPreferencesProvider)
            .setString(_lastWalletKey, wallet.id);
      }
      await HapticFeedback.mediumImpact();

      // Warn (once) when this entry takes the source below its threshold.
      final threshold = from.lowAlert;
      final before = balances[from.id];
      if (threshold != null && before != null) {
        final after = before - sourceOutflow;
        if (before > threshold && after <= threshold) {
          await ref
              .read(notificationServiceProvider)
              .showLowBalance(
                id: from.id.hashCode & 0xffff,
                title: l10n.notifLowTitle,
                body: l10n.notifLowBody(from.label),
              );
        }
      }
      if (mounted) Navigator.of(context).pop(id);
    } on PostingException {
      _failed(l10n.entrySaveFailed);
    } on DayLockedException {
      _failed(l10n.entryDayClosed);
    }
  }

  void _failed(String message) {
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

  Widget _customerField(AppLocalizations l10n, bool suggest) {
    final decoration = InputDecoration(labelText: l10n.entryCustomerNumber);
    if (!suggest) {
      return TextField(
        controller: _customer,
        keyboardType: TextInputType.phone,
        decoration: decoration,
      );
    }
    return RawAutocomplete<CustomerSuggestion>(
      textEditingController: _customer,
      focusNode: _customerFocus,
      displayStringForOption: (o) => o.phone,
      optionsBuilder: (value) => ref
          .read(customerRepositoryProvider)
          .suggest(DigitFormatter.toLatin(value.text)),
      onSelected: (o) => setState(() => _customerName.text = o.name ?? ''),
      fieldViewBuilder: (context, controller, focusNode, onSubmit) => TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.phone,
        decoration: decoration,
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220, maxWidth: 320),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final o in options)
                  ListTile(
                    title: Text(o.phone),
                    subtitle: o.name == null ? null : Text(o.name!),
                    onTap: () => onSelected(o),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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
    final lastAmount = widget.edit == null ? quick?.last : null;

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

    final isFlexi = widget.kind == EntryKind.flexiload;
    final earnsCommission =
        widget.kind == EntryKind.cashOut ||
        widget.kind == EntryKind.cashIn ||
        isFlexi;

    var commission = Money.zero;
    String? ruleId;
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

    // Float purchase: what was actually paid may differ from what arrives.
    var charge = Money.zero;
    var discount = Money.zero;
    final showPaid =
        widget.kind == EntryKind.floatPurchase &&
        wallet?.kind == AccountKind.load;
    final paid = showPaid
        ? Money.tryParse(DigitFormatter.toLatin(_paid.text.trim()))
        : null;
    if (paid != null && paid.isPositive && _entry.amount.isPositive) {
      if (paid > _entry.amount) {
        charge = paid - _entry.amount;
      } else if (paid < _entry.amount) {
        discount = _entry.amount - paid;
      }
    }

    // What leaves the source account (flexiload: cost = price - margin).
    final sourceOutflow = isFlexi
        ? _entry.amount - commission
        : _entry.amount + charge - discount;

    final from = legs.from;
    final to = legs.to;
    final negative =
        from != null &&
        _entry.amount.isPositive &&
        (balances[from.id] ?? Money.zero) - sourceOutflow < Money.zero;
    final canSave =
        _entry.amount.isPositive && from != null && to != null && !_saving;

    final direction = switch (widget.kind) {
      EntryKind.cashIn || EntryKind.flexiload => tokens.cashIn,
      EntryKind.cashOut || EntryKind.expense => tokens.cashOut,
      EntryKind.floatPurchase => theme.colorScheme.primary,
    };

    final emptyWalletText = isFlexi ? l10n.entryNoOperator : l10n.entryNoWallet;

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
                    if (isFlexi)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          l10n.entryOperator,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                    if (wallets.isEmpty)
                      Text(emptyWalletText)
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
                          ? (isFlexi
                                ? l10n.entryMargin(money.format(commission))
                                : l10n.entryCommission(
                                    money.format(commission),
                                  ))
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
                      if (showPaid)
                        TextField(
                          controller: _paid,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.entryPaidAmount,
                            prefixText: '৳ ',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      _customerField(l10n, prefs.rememberCustomers),
                      if (prefs.rememberCustomers)
                        TextField(
                          controller: _customerName,
                          decoration: InputDecoration(
                            labelText: l10n.entryCustomerName,
                          ),
                        ),
                      if (!isFlexi)
                        TextField(
                          controller: _trxId,
                          decoration: InputDecoration(
                            labelText: l10n.entryTrxId,
                          ),
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
                          from: from,
                          to: to,
                          wallet: needsWallet ? wallet : null,
                          commission: commission,
                          ruleId: ruleId,
                          sourceOutflow: sourceOutflow,
                          charge: charge,
                          discount: discount,
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
