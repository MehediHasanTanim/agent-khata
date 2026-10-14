import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/widgets/khata_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../entry/amount_entry.dart';
import '../entry/amount_keypad.dart';
import 'dues_service.dart';

/// Create a baki: who, how much, and which pocket the money came from (or
/// went into).
class DueFormScreen extends ConsumerStatefulWidget {
  const DueFormScreen({super.key});

  @override
  ConsumerState<DueFormScreen> createState() => _DueFormScreenState();
}

class _DueFormScreenState extends ConsumerState<DueFormScreen> {
  DueDirection _direction = DueDirection.theyOwe;
  AmountEntry _entry = const AmountEntry();
  String? _accountId;
  bool _saving = false;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _hasWho =>
      _name.text.trim().isNotEmpty || _phone.text.trim().isNotEmpty;

  Future<void> _save(String accountId) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(duesServiceProvider)
          .create(
            direction: _direction,
            amount: _entry.amount,
            accountId: accountId,
            name: _name.text,
            phone: DigitFormatter.toLatin(_phone.text),
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            createdBy: currentUserId(ref),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.duesSaved)));
      Navigator.of(context).pop();
    } on Object {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.duesFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];

    // They owe me: goods leave cash, a wallet or a load account.
    // I owe them: money arrives in cash or a wallet.
    final theyOwe = _direction == DueDirection.theyOwe;
    final choices = [
      for (final a in accounts)
        if (a.kind == AccountKind.cash ||
            a.kind == AccountKind.wallet ||
            (theyOwe && a.kind == AccountKind.load))
          a,
    ];
    final selected =
        choices.where((a) => a.id == _accountId).firstOrNull ??
        (choices.isEmpty ? null : choices.first);
    final canSave =
        _entry.amount.isPositive && _hasWho && selected != null && !_saving;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.duesNewTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  PillSegmented<DueDirection>(
                    value: _direction,
                    options: [
                      (DueDirection.theyOwe, l10n.duesTheyOwe),
                      (DueDirection.iOwe, l10n.duesIOwe),
                    ],
                    onChanged: (v) => setState(() {
                      _direction = v;
                      _accountId = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey('due-name'),
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(labelText: l10n.duesName),
                    onChanged: (_) => setState(() {}),
                  ),
                  TextField(
                    key: const ValueKey('due-phone'),
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: l10n.duesPhone),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (!_hasWho)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l10n.duesNeedNameOrPhone,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    theyOwe ? l10n.duesGaveFrom : l10n.duesReceivedIn,
                    style: theme.textTheme.labelLarge,
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final a in choices)
                        ChoiceChip(
                          label: Text(
                            a.kind == AccountKind.cash
                                ? l10n.homeCash
                                : a.label,
                          ),
                          selected: a.id == selected?.id,
                          onSelected: (_) => setState(() => _accountId = a.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      money.format(_entry.amount),
                      key: const ValueKey('due-amount'),
                      style: theme.textTheme.displayMedium,
                    ),
                  ),
                  TextField(
                    controller: _note,
                    decoration: InputDecoration(labelText: l10n.duesNote),
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
                  key: const ValueKey('due-save'),
                  onPressed: canSave ? () => _save(selected.id) : null,
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
