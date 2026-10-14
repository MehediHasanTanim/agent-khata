import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/ads/ad_widgets.dart';
import '../../core/i18n/date_labels.dart';
import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../entry/amount_entry.dart';
import '../entry/amount_keypad.dart';
import 'dues_service.dart';

/// One baki: remaining amount, payments so far, record a payment, call/SMS.
class DueDetailScreen extends ConsumerStatefulWidget {
  const DueDetailScreen({super.key, required this.dueId});

  final String dueId;

  @override
  ConsumerState<DueDetailScreen> createState() => _DueDetailScreenState();
}

class _DueDetailScreenState extends ConsumerState<DueDetailScreen> {
  DueView? _due;
  List<SettlementView> _payments = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = ref.read(duesServiceProvider);
    final due = await service.byId(widget.dueId);
    final payments = await service.settlements(widget.dueId);
    if (!mounted) return;
    setState(() {
      _due = due;
      _payments = payments;
      _loaded = true;
    });
  }

  Future<void> _launch(String scheme, String phone) async {
    await launchUrl(Uri(scheme: scheme, path: phone));
  }

  Future<void> _settle(DueView due) async {
    final done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SettleSheet(due: due),
    );
    if (done == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final labels = DateLabels(
      languageCode: prefs.languageCode,
      digits: prefs.digits,
    );
    final due = _due;

    return Scaffold(
      bottomNavigationBar: const AdFooter(),
      appBar: AppBar(title: Text(due?.displayName ?? l10n.duesTitle)),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : due == null
          ? Center(child: Text(l10n.duesEmpty))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  due.direction == DueDirection.theyOwe
                      ? l10n.duesTheyOwe
                      : l10n.duesIOwe,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.duesRemaining(money.format(due.remaining)),
                  style: theme.textTheme.displaySmall,
                ),
                Text(
                  l10n.duesOriginal(money.format(due.original)),
                  style: theme.textTheme.bodyMedium,
                ),
                if (due.note != null) ...[
                  const SizedBox(height: 8),
                  Text(due.note!, style: theme.textTheme.bodyLarge),
                ],
                if (due.customerPhone != null) ...[
                  const SizedBox(height: 12),
                  Text(due.customerPhone!, style: theme.textTheme.bodyLarge),
                  Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.call_outlined),
                        label: Text(l10n.duesCall),
                        onPressed: () => _launch('tel', due.customerPhone!),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.sms_outlined),
                        label: Text(l10n.duesSms),
                        onPressed: () => _launch('sms', due.customerPhone!),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                if (due.isOpen)
                  FilledButton.icon(
                    key: const ValueKey('settle'),
                    icon: const Icon(Icons.payments_outlined),
                    label: Text(
                      due.direction == DueDirection.theyOwe
                          ? l10n.duesSettle
                          : l10n.duesSettleReturn,
                    ),
                    onPressed: () => _settle(due),
                  ),
                const Divider(height: 32),
                Text(l10n.duesPayments, style: theme.textTheme.titleMedium),
                if (_payments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l10n.duesNoPayments),
                  ),
                for (final p in _payments)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      money.format(p.amount),
                      style: TextStyle(
                        decoration: p.isVoid
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(labels.dateTime(p.at)),
                  ),
              ],
            ),
    );
  }
}

class _SettleSheet extends ConsumerStatefulWidget {
  const _SettleSheet({required this.due});

  final DueView due;

  @override
  ConsumerState<_SettleSheet> createState() => _SettleSheetState();
}

class _SettleSheetState extends ConsumerState<_SettleSheet> {
  AmountEntry _entry = const AmountEntry();
  String? _accountId;
  bool _saving = false;
  String? _error;

  Future<void> _save(String accountId) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(duesServiceProvider)
          .settle(
            dueId: widget.due.id,
            amount: _entry.amount,
            accountId: accountId,
            createdBy: currentUserId(ref),
          );
      if (mounted) Navigator.of(context).pop(true);
    } on DueException catch (e) {
      setState(() {
        _saving = false;
        _error = e.code == 'over_settle'
            ? l10n.duesOverSettle
            : l10n.duesFailed;
      });
    } on Object {
      setState(() {
        _saving = false;
        _error = l10n.duesFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final choices = [
      for (final a in accounts)
        if (a.kind == AccountKind.cash || a.kind == AccountKind.wallet) a,
    ];
    final selected =
        choices.where((a) => a.id == _accountId).firstOrNull ??
        (choices.isEmpty ? null : choices.first);
    final theyOwe = widget.due.direction == DueDirection.theyOwe;
    final remaining = widget.due.remaining;
    final over = _entry.amount > remaining;
    final canSave =
        _entry.amount.isPositive && !over && selected != null && !_saving;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              theyOwe ? l10n.duesSettle : l10n.duesSettleReturn,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final a in choices)
                  ChoiceChip(
                    label: Text(
                      a.kind == AccountKind.cash ? l10n.homeCash : a.label,
                    ),
                    selected: a.id == selected?.id,
                    onSelected: (_) => setState(() => _accountId = a.id),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              money.format(_entry.amount),
              key: const ValueKey('settle-amount'),
              style: theme.textTheme.displayMedium?.copyWith(
                color: over ? theme.colorScheme.error : null,
              ),
            ),
            Text(
              over
                  ? l10n.duesOverSettle
                  : l10n.duesRemaining(money.format(remaining)),
            ),
            if (_error != null)
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            TextButton(
              onPressed: () => setState(() => _entry = _entry.set(remaining)),
              child: Text(l10n.duesSettleAll),
            ),
            AmountKeypad(
              digits: prefs.digits,
              chips: const [],
              onKey: (k) => setState(() => _entry = _entry.press(k)),
              onBackspace: () => setState(() => _entry = _entry.backspace()),
              onChip: (m) => setState(() => _entry = _entry.set(m)),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                key: const ValueKey('settle-save'),
                onPressed: canSave ? () => _save(selected.id) : null,
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
