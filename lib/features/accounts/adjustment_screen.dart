import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/ledger/account.dart';
import '../../core/ledger/transaction_draft.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../entry/amount_entry.dart';
import '../entry/amount_keypad.dart';

/// Manual balance correction with a mandatory reason (S3-09). Posts through
/// the adjustment strategy so the ledger still balances.
class AdjustmentScreen extends ConsumerStatefulWidget {
  const AdjustmentScreen({super.key, required this.account});

  final Account account;

  @override
  ConsumerState<AdjustmentScreen> createState() => _AdjustmentScreenState();
}

class _AdjustmentScreenState extends ConsumerState<AdjustmentScreen> {
  AmountEntry _entry = const AmountEntry();
  bool _increase = true;
  bool _saving = false;
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final id = widget.account.id;
      await ref
          .read(transactionRepositoryProvider)
          .post(
            TransactionDraft(
              type: TransactionType.adjustment,
              occurredAt: DateTime.now().toUtc(),
              amount: _entry.amount,
              toAccountId: _increase ? id : null,
              fromAccountId: _increase ? null : id,
              note: _reason.text.trim(),
              createdBy: currentUserId(ref),
            ),
          );
      if (mounted) Navigator.of(context).pop();
    } on Object {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.entrySaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final current =
        ref.watch(balancesProvider).value?[widget.account.id] ?? Money.zero;
    final next = _increase ? current + _entry.amount : current - _entry.amount;
    final canSave =
        _entry.amount.isPositive && _reason.text.trim().isNotEmpty && !_saving;

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.adjTitle} · ${widget.account.label}')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        icon: const Icon(LucideIcons.plus),
                        label: Text(l10n.adjIncrease),
                      ),
                      ButtonSegment(
                        value: false,
                        icon: const Icon(LucideIcons.minus),
                        label: Text(l10n.adjDecrease),
                      ),
                    ],
                    selected: {_increase},
                    onSelectionChanged: (s) =>
                        setState(() => _increase = s.first),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      money.format(_entry.amount),
                      style: theme.textTheme.displayMedium,
                    ),
                  ),
                  Center(
                    child: Text(
                      l10n.adjCurrent(money.format(current)),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Center(
                    child: Text(
                      l10n.adjNew(money.format(next)),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reason,
                    decoration: InputDecoration(labelText: l10n.adjReason),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            AmountKeypad(
              digits: prefs.digits,
              chips: const [],
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
                  onPressed: canSave ? _save : null,
                  child: Text(l10n.save),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
