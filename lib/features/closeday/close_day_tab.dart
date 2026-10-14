import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/i18n/date_labels.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/security/roles.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/business_calendar.dart';
import '../../l10n/gen/app_localizations.dart';
import '../shifts/shift_service.dart';
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
  List<ShiftInfo> _shifts = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_refresh);
  }

  Future<void> _refresh() async {
    final days = await ref.read(dayCloseServiceProvider).recent();
    final session = ref.read(sessionProvider);
    final ownOnly =
        session != null && !Permissions.can(session, Permission.viewAllHistory);
    final shifts = await ref
        .read(shiftServiceProvider)
        .recent(userId: ownOnly ? session.id : null);
    if (mounted) {
      setState(() {
        _days = days;
        _shifts = shifts;
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
          .reopen(day.businessDate, reason: reason, userId: currentUserId(ref));
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
    final session = ref.watch(sessionProvider);
    final canClose =
        session != null && Permissions.can(session, Permission.closeDay);
    final canReopen =
        session != null && Permissions.can(session, Permission.reopenDay);
    final names = ref.watch(userNamesProvider);
    final unclosedYesterday = canClose
        ? ref.watch(unclosedYesterdayProvider).value
        : null;

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
              color: Color.alphaBlend(
                tokens.warning.withValues(alpha: 0.16),
                theme.colorScheme.surface,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: tokens.warning, width: 1.5),
              ),
              child: ListTile(
                leading: Icon(LucideIcons.triangleAlert, color: tokens.warning),
                title: Text(l10n.cdYesterdayOpen),
                subtitle: Text(dateText(unclosedYesterday)),
                trailing: FilledButton(
                  onPressed: () => _open(unclosedYesterday),
                  child: Text(l10n.cdClose),
                ),
              ),
            ),
          if (canClose)
            Card(
              child: ListTile(
                leading: const Icon(LucideIcons.clipboardCheck),
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
          if (!canClose)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.closeDayNoPermission),
            ),
          const SizedBox(height: 16),
          Text(l10n.shiftRecent, style: theme.textTheme.titleMedium),
          if (_loaded && _shifts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.shiftNone),
            ),
          for (final sh in _shifts.take(8))
            ListTile(
              key: ValueKey('shift-${sh.id}'),
              contentPadding: EdgeInsets.zero,
              leading: Icon(sh.isOpen ? LucideIcons.play : LucideIcons.check),
              title: Text(
                sh.userId == kOwnerUserId
                    ? l10n.roleOwner
                    : (names[sh.userId] ?? sh.userName ?? ''),
              ),
              subtitle: Text(
                '${labels.dateTime(sh.startedAt)}'
                '${sh.endedAt == null ? '' : ' → ${labels.time(sh.endedAt!)}'}',
              ),
              trailing: sh.isOpen
                  ? Text(l10n.shiftOpenNow)
                  : Text(
                      (sh.totalVariance ?? Money.zero).isZero
                          ? l10n.cdMatches
                          : l10n.shiftDifference(
                              money.format(sh.totalVariance!),
                            ),
                      style: TextStyle(
                        color: (sh.totalVariance ?? Money.zero).isZero
                            ? null
                            : tokens.warning,
                      ),
                    ),
            ),
          if (canClose) ...[
            const Divider(height: 32),
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
                  day.status == 'closed'
                      ? LucideIcons.lock
                      : LucideIcons.lockOpen,
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
                    day.status == 'closed' &&
                        canReopen &&
                        day.businessDate == latestClosedId
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
        ],
      ),
    );
  }
}
