import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/security/roles.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import '../commission/commission_engine.dart';
import '../transactions/bulk_flexiload_service.dart';
import '../transactions/transaction_repository.dart';
import 'bulk_flexiload.dart';

class _RowState {
  _RowState({String number = '', String amount = ''})
    : number = TextEditingController(text: number),
      amount = TextEditingController(text: amount);

  final TextEditingController number;
  final TextEditingController amount;

  BulkRow toRow() => BulkRow(
    number: number.text,
    amount: Money.tryParse(
      DigitFormatter.toLatin(amount.text).replaceAll(',', '').trim(),
    ),
  );

  void dispose() {
    number.dispose();
    amount.dispose();
  }
}

/// Enter or paste several flexiload sales for one operator and save them
/// together (all or none).
class BulkFlexiloadScreen extends ConsumerStatefulWidget {
  const BulkFlexiloadScreen({super.key});

  @override
  ConsumerState<BulkFlexiloadScreen> createState() =>
      _BulkFlexiloadScreenState();
}

class _BulkFlexiloadScreenState extends ConsumerState<BulkFlexiloadScreen> {
  static const _engine = CommissionEngine();

  final List<_RowState> _rows = [_RowState(), _RowState(), _RowState()];
  String? _operatorId;
  bool _saving = false;
  String? _skipped;

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _paste() async {
    final l10n = AppLocalizations.of(context);
    final c = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bulkPaste),
        content: TextField(
          controller: c,
          autofocus: true,
          minLines: 5,
          maxLines: 10,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(hintText: l10n.bulkPasteHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text),
            child: Text(l10n.bulkPasteApply),
          ),
        ],
      ),
    );
    c.dispose();
    if (text == null || text.trim().isEmpty) return;
    final parsed = parseBulkLines(text);
    setState(() {
      // Replace empty placeholder rows first, then append.
      _rows.removeWhere((r) => r.toRow().isBlank);
      for (final r in parsed.rows) {
        _rows.add(
          _RowState(number: r.number, amount: '${r.amount!.wholeTaka}'),
        );
      }
      if (_rows.isEmpty) _rows.add(_RowState());
      _skipped = parsed.rejected.isEmpty
          ? null
          : l10n.bulkRejected(
              ref
                  .read(preferencesProvider)
                  .digits
                  .localize('${parsed.rejected.length}'),
            );
    });
  }

  Future<void> _saveAll({
    required Account operator,
    required Account cash,
    required List<BulkRow> rows,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final digits = ref.read(preferencesProvider).digits;
    final rules = ref.read(commissionRulesProvider).value ?? const [];
    final service = BulkFlexiloadService(
      ref.read(databaseProvider),
      ref.read(transactionRepositoryProvider),
    );
    final userId = currentUserId(ref);
    final now = DateTime.now().toUtc();
    final provider = operator.provider ?? '';

    Money marginFor(Money price) => _engine
        .compute(
          rules: rules,
          provider: provider,
          type: TransactionType.flexiload,
          amount: price,
          at: now,
        )
        .amount;

    setState(() => _saving = true);
    try {
      final ids = await service.save(
        operatorAccountId: operator.id,
        cashAccountId: cash.id,
        rows: rows,
        marginFor: marginFor,
        createdBy: userId,
        at: now,
      );
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.bulkSaved(digits.localize('${ids.length}'))),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: l10n.undo,
              onPressed: () => service.voidAll(ids, userId: userId),
            ),
          ),
        );
      navigator.pop(true);
    } on PermissionDenied {
      _failed(l10n.permDenied);
    } on DayLockedException {
      _failed(l10n.entryDayClosed);
    } on Object {
      _failed(l10n.entrySaveFailed);
    }
  }

  void _failed(String message) {
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

    final operators = [
      for (final a in accounts)
        if (a.kind == AccountKind.load) a,
    ];
    final operator =
        operators.where((o) => o.id == _operatorId).firstOrNull ??
        (operators.isEmpty ? null : operators.first);
    final cash = accounts.where((a) => a.kind == AccountKind.cash).firstOrNull;

    final rows = [for (final r in _rows) r.toRow()];
    final dups = duplicateRowIndexes(rows);
    final complete = [
      for (final r in rows)
        if (r.isComplete) r,
    ];
    final started = [
      for (final r in rows)
        if (!r.isBlank) r,
    ];
    final incomplete = started.length - complete.length;

    var price = Money.zero;
    var margin = Money.zero;
    final now = DateTime.now().toUtc();
    for (final r in complete) {
      price += r.amount!;
      if (operator?.provider != null) {
        margin += _engine
            .compute(
              rules: rules,
              provider: operator!.provider!,
              type: TransactionType.flexiload,
              amount: r.amount!,
              at: now,
            )
            .amount;
      }
    }
    final cost = price - margin;
    final lowBalance =
        operator != null &&
        complete.isNotEmpty &&
        (balances[operator.id] ?? Money.zero) - cost < Money.zero;

    final canSave =
        complete.isNotEmpty &&
        incomplete == 0 &&
        operator != null &&
        cash != null &&
        !_saving;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bulkTitle),
        actions: [
          IconButton(
            tooltip: l10n.bulkPaste,
            icon: const Icon(LucideIcons.clipboardPaste),
            onPressed: _paste,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                children: [
                  Text(l10n.entryOperator, style: theme.textTheme.labelLarge),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final o in operators)
                        ChoiceChip(
                          key: ValueKey('op-${o.id}'),
                          label: Text(o.label),
                          selected: o.id == operator?.id,
                          onSelected: (_) => setState(() => _operatorId = o.id),
                        ),
                    ],
                  ),
                  if (operators.isEmpty) Text(l10n.entryNoOperator),
                  if (_skipped != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _skipped!,
                        style: TextStyle(color: tokens.warning),
                      ),
                    ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < _rows.length; i++)
                    _RowTile(
                      key: ObjectKey(_rows[i]),
                      index: i,
                      state: _rows[i],
                      numberLabel: l10n.bulkNumber,
                      amountLabel: l10n.bulkAmount,
                      warning: dups.contains(i)
                          ? l10n.bulkDuplicate
                          : (_rows[i].number.text.trim().isNotEmpty &&
                                    !isValidBdMobile(
                                      normalizeMobile(_rows[i].number.text),
                                    )
                                ? l10n.bulkBadNumber
                                : null),
                      warningColor: tokens.warning,
                      onChanged: () => setState(() {}),
                      onDelete: _rows.length <= 1
                          ? null
                          : () => setState(() {
                              _rows.removeAt(i).dispose();
                            }),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          key: const ValueKey('bulk-add-row'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            backgroundColor:
                                theme.colorScheme.tertiaryContainer,
                            foregroundColor: theme.colorScheme.onSurface,
                          ),
                          icon: const Icon(LucideIcons.plus),
                          label: Text(l10n.bulkAddRow),
                          onPressed: () =>
                              setState(() => _rows.add(_RowState())),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            foregroundColor:
                                theme.colorScheme.onSecondaryContainer,
                          ),
                          icon: const Icon(LucideIcons.clipboardPaste),
                          label: Text(l10n.bulkPaste),
                          onPressed: _paste,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Material(
              elevation: 8,
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.bulkTotal(
                                digits.localize('${complete.length}'),
                                money.format(price),
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          Text(
                            l10n.bulkMargin(money.format(margin)),
                            style: TextStyle(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (lowBalance)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.triangleAlert,
                              color: tokens.warning,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                l10n.bulkLowBalance(operator.label),
                                style: TextStyle(color: tokens.warning),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: FilledButton(
                        key: const ValueKey('bulk-save'),
                        onPressed: canSave
                            ? () => _saveAll(
                                operator: operator,
                                cash: cash,
                                rows: rows,
                              )
                            : null,
                        child: Text(
                          l10n.bulkSaveAll(
                            digits.localize('${complete.length}'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    super.key,
    required this.index,
    required this.state,
    required this.numberLabel,
    required this.amountLabel,
    required this.warning,
    required this.warningColor,
    required this.onChanged,
    required this.onDelete,
  });

  final int index;
  final _RowState state;
  final String numberLabel;
  final String amountLabel;
  final String? warning;
  final Color warningColor;
  final VoidCallback onChanged;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  key: ValueKey('bulk-number-$index'),
                  controller: state.number,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: numberLabel),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  key: ValueKey('bulk-amount-$index'),
                  controller: state.amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: amountLabel,
                    prefixText: '৳ ',
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
              IconButton(
                tooltip: '×',
                icon: const Icon(LucideIcons.x),
                onPressed: onDelete,
              ),
            ],
          ),
          if (warning != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: warningColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  warning!,
                  style: TextStyle(
                    color: warningColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
