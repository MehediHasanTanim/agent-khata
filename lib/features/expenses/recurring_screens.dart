import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/ads/ad_widgets.dart';
import '../../core/i18n/date_labels.dart';
import '../../core/i18n/digit_formatter.dart';
import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/widgets/khata_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../entry/entry_providers.dart';
import '../transactions/transaction_repository.dart';
import 'recurrence.dart';
import 'recurring_expense_service.dart';

String _weekdayName(AppLocalizations l10n, int weekday) => [
  l10n.wdMon,
  l10n.wdTue,
  l10n.wdWed,
  l10n.wdThu,
  l10n.wdFri,
  l10n.wdSat,
  l10n.wdSun,
][weekday - 1];

String _dateText(DateLabels labels, String businessDate) {
  final p = businessDate.split('-').map(int.parse).toList();
  return labels.day(DateTime.utc(p[0], p[1], p[2], 6));
}

String _scheduleText(AppLocalizations l10n, Recurrence r, DigitFormatter d) =>
    r.frequency == RecurrenceFrequency.monthly
    ? '${l10n.recMonthly} · ${d.localize('${r.day}')}'
    : '${l10n.recWeekly} · ${_weekdayName(l10n, r.day)}';

/// Owner: list of templates, add and edit.
class RecurringExpensesScreen extends ConsumerWidget {
  const RecurringExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final labels = DateLabels(
      languageCode: prefs.languageCode,
      digits: prefs.digits,
    );
    final items =
        ref.watch(_allRecurringProvider).value ?? const <RecurringExpense>[];

    return Scaffold(
      bottomNavigationBar: const AdFooter(),
      appBar: AppBar(title: Text(l10n.recTitle)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(l10n.recEmpty)),
            ),
          for (final r in items)
            KhataTile(
              key: ValueKey('recurring-${r.id}'),
              leading: DirectionBubble(
                icon: r.isActive ? LucideIcons.repeat : LucideIcons.pause,
                out: true,
                muted: !r.isActive,
              ),
              title: Text(r.categoryLabel ?? ''),
              subtitle: Text(
                [
                  _scheduleText(l10n, r.recurrence, prefs.digits),
                  if (r.isActive)
                    l10n.recNextDue(_dateText(labels, r.nextDueDate))
                  else
                    l10n.recPaused,
                ].join(' · '),
              ),
              trailing: Text(
                money.format(r.amount),
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => RecurringFormScreen(existing: r),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: FilledButton.icon(
              key: const ValueKey('add-recurring'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
              icon: const Icon(LucideIcons.plus),
              label: Text(l10n.recAdd),
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const RecurringFormScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _allRecurringProvider =
    StreamProvider.autoDispose<List<RecurringExpense>>(
      (ref) => ref.watch(recurringExpenseServiceProvider).watchAll(),
    );

class RecurringFormScreen extends ConsumerStatefulWidget {
  const RecurringFormScreen({super.key, this.existing});

  final RecurringExpense? existing;

  @override
  ConsumerState<RecurringFormScreen> createState() =>
      _RecurringFormScreenState();
}

class _RecurringFormScreenState extends ConsumerState<RecurringFormScreen> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.existing == null ? '' : '${widget.existing!.amount.wholeTaka}',
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.existing?.note ?? '',
  );
  late RecurrenceFrequency _frequency =
      widget.existing?.recurrence.frequency ?? RecurrenceFrequency.monthly;
  late int _monthDay =
      widget.existing?.recurrence.frequency == RecurrenceFrequency.monthly
      ? widget.existing!.recurrence.day
      : 1;
  late int _weekday =
      widget.existing?.recurrence.frequency == RecurrenceFrequency.weekly
      ? widget.existing!.recurrence.day
      : DateTime.saturday;
  late String? _category = widget.existing?.categoryAccountId;
  late String? _source = widget.existing?.sourceAccountId;
  late bool _active = widget.existing?.isActive ?? true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Money? get _parsedAmount => Money.tryParse(
    DigitFormatter.toLatin(_amount.text).replaceAll(',', '').trim(),
  );

  Recurrence get _recurrence => _frequency == RecurrenceFrequency.monthly
      ? Recurrence.monthly(_monthDay)
      : Recurrence.weekly(_weekday);

  Future<void> _save({required String category, required String source}) async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(recurringExpenseServiceProvider);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final note = _note.text.trim();
      if (widget.existing == null) {
        await service.create(
          categoryAccountId: category,
          sourceAccountId: source,
          amount: _parsedAmount!,
          recurrence: _recurrence,
          note: note.isEmpty ? null : note,
        );
      } else {
        await service.update(
          widget.existing!.id,
          amount: _parsedAmount,
          recurrence: _recurrence,
          categoryAccountId: category,
          sourceAccountId: source,
          note: note,
          isActive: _active,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on Object {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = l10n.duesFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final digits = prefs.digits;
    final categories = ref.watch(expenseAccountsProvider).value ?? const [];
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final sources = [
      for (final a in accounts)
        if (a.kind == AccountKind.cash || a.kind == AccountKind.bank) a,
    ];
    final category =
        categories.where((c) => c.id == _category).firstOrNull ??
        (categories.isEmpty ? null : categories.first);
    final source =
        sources.where((s) => s.id == _source).firstOrNull ??
        (sources.isEmpty ? null : sources.first);
    final amount = _parsedAmount;
    final canSave =
        !_busy &&
        category != null &&
        source != null &&
        amount != null &&
        amount.isPositive;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? l10n.recAdd : l10n.recTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (categories.isEmpty) Text(l10n.recNeedCategory),
          Text(l10n.entryCategory, style: theme.textTheme.labelLarge),
          Wrap(
            spacing: 8,
            children: [
              for (final c in categories)
                ChoiceChip(
                  key: ValueKey('rec-cat-${c.id}'),
                  label: Text(c.label),
                  selected: c.id == category?.id,
                  onSelected: (_) => setState(() => _category = c.id),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('rec-amount'),
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.recAmount,
              prefixText: '৳ ',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          PillSegmented<RecurrenceFrequency>(
            value: _frequency,
            options: [
              (RecurrenceFrequency.monthly, l10n.recMonthly),
              (RecurrenceFrequency.weekly, l10n.recWeekly),
            ],
            onChanged: (v) => setState(() => _frequency = v),
          ),
          const SizedBox(height: 12),
          if (_frequency == RecurrenceFrequency.monthly) ...[
            DropdownButtonFormField<int>(
              key: const ValueKey('rec-day'),
              initialValue: _monthDay,
              decoration: InputDecoration(labelText: l10n.recDayOfMonth),
              items: [
                for (var d = 1; d <= 31; d++)
                  DropdownMenuItem(
                    value: d,
                    child: Text(digits.localize('$d')),
                  ),
              ],
              onChanged: (v) => setState(() => _monthDay = v ?? 1),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l10n.recEvery31, style: theme.textTheme.bodyMedium),
            ),
          ] else
            DropdownButtonFormField<int>(
              initialValue: _weekday,
              decoration: InputDecoration(labelText: l10n.recWeekday),
              items: [
                for (var d = 1; d <= 7; d++)
                  DropdownMenuItem(
                    value: d,
                    child: Text(_weekdayName(l10n, d)),
                  ),
              ],
              onChanged: (v) => setState(() => _weekday = v ?? 1),
            ),
          const SizedBox(height: 12),
          if (sources.length > 1) ...[
            Text(l10n.entryPaidFrom, style: theme.textTheme.labelLarge),
            Wrap(
              spacing: 8,
              children: [
                for (final s in sources)
                  ChoiceChip(
                    label: Text(
                      s.kind == AccountKind.cash ? l10n.homeCash : s.label,
                    ),
                    selected: s.id == source?.id,
                    onSelected: (_) => setState(() => _source = s.id),
                  ),
              ],
            ),
          ],
          TextField(
            controller: _note,
            decoration: InputDecoration(labelText: l10n.entryNote),
          ),
          if (widget.existing != null)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _active,
              title: Text(l10n.staffActivate),
              onChanged: (v) => setState(() => _active = v),
            ),
          if (_error != null)
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 16),
          FilledButton(
            key: const ValueKey('rec-save'),
            onPressed: canSave
                ? () => _save(category: category.id, source: source.id)
                : null,
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

/// Occurrences that have come due, to record or skip.
class RecurringDueScreen extends ConsumerStatefulWidget {
  const RecurringDueScreen({super.key});

  @override
  ConsumerState<RecurringDueScreen> createState() => _RecurringDueScreenState();
}

class _RecurringDueScreenState extends ConsumerState<RecurringDueScreen> {
  List<RecurringExpense> _due = const [];
  String _today = '';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = ref.read(recurringExpenseServiceProvider);
    final due = await service.due();
    final today = await service.todayBusinessDate();
    if (!mounted) return;
    setState(() {
      _due = due;
      _today = today;
      _loaded = true;
    });
    ref.invalidate(recurringDueProvider);
  }

  Future<void> _act(RecurringExpense r, {required bool record}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(recurringExpenseServiceProvider);
    try {
      if (record) {
        await service.record(r.id, userId: currentUserId(ref));
        messenger.showSnackBar(SnackBar(content: Text(l10n.recRecorded)));
      } else {
        await service.skip(r.id, userId: currentUserId(ref));
      }
    } on DayLockedException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.entryDayClosed)));
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.entrySaveFailed)));
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final labels = DateLabels(
      languageCode: prefs.languageCode,
      digits: prefs.digits,
    );
    return Scaffold(
      bottomNavigationBar: const AdFooter(),
      appBar: AppBar(title: Text(l10n.recTitle)),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (_due.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(l10n.recEmpty)),
                  ),
                for (final r in _due)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${r.categoryLabel ?? ''} · ${money.format(r.amount)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${l10n.recDueNow}: ${_dateText(labels, r.nextDueDate)}'
                            '${r.recurrence.dueCount(r.nextDueDate, _today) > 1 ? ' (+${prefs.digits.localize('${r.recurrence.dueCount(r.nextDueDate, _today) - 1}')})' : ''}',
                          ),
                          if (r.note != null) Text(r.note!),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  key: ValueKey('rec-record-${r.id}'),
                                  onPressed: () => _act(r, record: true),
                                  child: Text(l10n.recRecord),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonal(
                                key: ValueKey('rec-skip-${r.id}'),
                                onPressed: () => _act(r, record: false),
                                child: Text(l10n.recSkip),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
