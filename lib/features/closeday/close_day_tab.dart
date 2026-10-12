import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/date_labels.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/business_calendar.dart';
import '../../l10n/gen/app_localizations.dart';
import 'close_day_screen.dart';
import 'daily_summary_screen.dart';
import 'day_close_service.dart';

/// "Close day" tab: start today's (or yesterday's) close and review past
/// days, with owner-only reopen of the latest closed day.
class CloseDayTab extends ConsumerStatefulWidget {
  const CloseDayTab({super.key});

  @override
  ConsumerState<CloseDayTab> createState() => _CloseDayTabState();
}

class _CloseDayTabState extends ConsumerState<CloseDayTab> {
  List<ClosedDay> _days = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_refresh);
  }

  Future<void> _refresh() async {
    final days = await ref.read(dayCloseServiceProvider).recent();
    if (mounted) {
      setState(() {
        _days = days;
        _loaded = true;
      });
    }
  }

  Future<void> _open(String date) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => CloseDayScreen(businessDate: date)),
    );
    if (mounted) await _refresh();
  }

  Future<void> _reopen(ClosedDay day) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(l10n.cdReopenTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.cdReopenBody),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.detailVoidReason),
                onChanged: (_) => setLocal(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: controller.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.cdReopen),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (reason == null || !mounted) return;
    try {
      await ref
          .read(dayCloseServiceProvider)
          .reopen(day.businessDate, reason: reason);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.cdReopened)));
      }
    } on DayCloseException {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.cdLaterClosed)));
      }
    }
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final labels = DateLabels(
      languageCode: prefs.languageCode,
      digits: prefs.digits,
    );
    final rollover = ref.watch(dayRolloverHourProvider).value ?? 4;
    final cal = BusinessCalendar(rolloverHour: rollover);
    final today = cal.businessDateOf(DateTime.now().toUtc());
    final unclosedYesterday = ref.watch(unclosedYesterdayProvider).value;

    // Refresh the list whenever the ledger changes (close/reopen/entries).
    ref.listen(balancesProvider, (_, _) => _refresh());

    String dateText(String d) {
      final p = d.split('-').map(int.parse).toList();
      return labels.day(DateTime.utc(p[0], p[1], p[2], 6));
    }

    String statusText(String s) =>
        s == 'closed' ? l10n.cdStatusClosed : l10n.cdStatusReopened;

    final latestClosedId = _days
        .where((d) => d.status == 'closed')
        .map((d) => d.businessDate)
        .fold<String?>(null, (a, b) => a == null || b.compareTo(a) > 0 ? b : a);

    final todayClosed = _days.any(
      (d) => d.businessDate == today && d.status == 'closed',
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navCloseDay)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (unclosedYesterday != null)
            Card(
              color: tokens.warning.withValues(alpha: 0.15),
              child: ListTile(
                leading: Icon(Icons.warning_amber, color: tokens.warning),
                title: Text(l10n.cdYesterdayOpen),
                subtitle: Text(dateText(unclosedYesterday)),
                trailing: FilledButton(
                  onPressed: () => _open(unclosedYesterday),
                  child: Text(l10n.cdClose),
                ),
              ),
            ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: Text(l10n.homeToday),
              subtitle: Text(dateText(today)),
              trailing: todayClosed
                  ? Text(l10n.cdStatusClosed)
                  : FilledButton(
                      key: const ValueKey('close-today'),
                      onPressed: () => _open(today),
                      child: Text(l10n.cdClose),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.cdRecentDays, style: theme.textTheme.titleMedium),
          if (_loaded && _days.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(l10n.cdNoDays),
            ),
          for (final day in _days)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                day.status == 'closed' ? Icons.lock_outline : Icons.lock_open,
              ),
              title: Text(dateText(day.businessDate)),
              subtitle: Text(
                '${statusText(day.status)} · '
                '${day.totalVariance.isZero ? l10n.cdMatches : l10n.cdDifference(money.format(day.totalVariance))}',
              ),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) =>
                      DailySummaryScreen(businessDate: day.businessDate),
                ),
              ),
              trailing:
                  day.status == 'closed' && day.businessDate == latestClosedId
                  ? TextButton(
                      onPressed: () => _reopen(day),
                      child: Text(l10n.cdReopen),
                    )
                  : day.status == 'reopened'
                  ? TextButton(
                      onPressed: () => _open(day.businessDate),
                      child: Text(l10n.cdClose),
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}
