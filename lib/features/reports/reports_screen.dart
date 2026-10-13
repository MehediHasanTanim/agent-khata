import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/i18n/date_labels.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/security/roles.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/business_calendar.dart';
import '../../l10n/gen/app_localizations.dart';
import '../commission/commission_rates_screen.dart' show transactionTypeLabel;
import '../entry/entry_screen.dart';
import '../insights/insights_queries.dart';
import '../onboarding/provider_catalog.dart';
import '../shifts/shift_service.dart';
import '../transactions/history_filter.dart';
import '../transactions/history_queries.dart';
import 'csv_export.dart';
import 'mini_charts.dart';
import 'report_queries.dart';

enum _Period { week, month }

class _ReportData {
  const _ReportData(
    this.summary,
    this.variance,
    this.commission,
    this.operators,
    this.insights,
    this.varianceByAccount,
    this.varianceByWeekday,
  );

  final ReportSummary summary;
  final List<VariancePoint> variance;
  final List<CommissionComparison> commission;
  final List<OperatorVariance> operators;
  final Insights insights;
  final List<AccountVariance> varianceByAccount;
  final List<WeekdayVariance> varianceByWeekday;
}

/// Weekly and monthly summaries, day-close variance history, commission
/// expected vs received, and CSV export.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  _Period _period = _Period.month;
  String? _varianceAccountId; // null = all accounts
  int _offset = 0; // 0 = current, -1 = previous, ...
  _ReportData? _data;
  bool _exporting = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  ({DateTime start, DateTime end}) _range(int rolloverHour) {
    final cal = BusinessCalendar(rolloverHour: rolloverHour);
    final now = DateTime.now().toUtc();
    if (_period == _Period.week) {
      final end = cal.dayRange(now.add(Duration(days: 7 * _offset))).end;
      return (start: end.subtract(const Duration(days: 7)), end: end);
    }
    var instant = now;
    for (var i = 0; i < -_offset; i++) {
      instant = cal.monthRange(instant).start.subtract(const Duration(days: 1));
    }
    return cal.monthRange(instant);
  }

  Future<void> _load() async {
    final gen = ++_generation;
    final hour = await ref.read(dayRolloverHourProvider.future);
    final r = _range(hour);
    final q = ref.read(reportQueriesProvider);
    final summary = await q.summary(r.start, r.end, rolloverHour: hour);
    final variance = await q.varianceHistory(accountId: _varianceAccountId);
    final byAccount = await q.varianceByAccount();
    final byWeekday = await q.varianceByWeekday();
    final commission = await q.commissionComparison();
    final operators = await ref
        .read(shiftServiceProvider)
        .varianceByOperator(r.start, r.end);
    final insights = await ref
        .read(insightsQueriesProvider)
        .compute(r.start, r.end, rolloverHour: hour);
    if (!mounted || gen != _generation) return;
    setState(
      () => _data = _ReportData(
        summary,
        variance,
        commission,
        operators,
        insights,
        byAccount,
        byWeekday,
      ),
    );
  }

  Future<void> _exportCsv() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _exporting = true);
    try {
      final hour = await ref.read(dayRolloverHourProvider.future);
      final r = _range(hour);
      final history = ref.read(historyQueriesProvider);
      final items = <HistoryItem>[];
      HistoryCursor? cursor;
      final filter = HistoryFilter(from: r.start, to: r.end);
      while (true) {
        final page = await history.page(filter, after: cursor, limit: 500);
        if (page.isEmpty) break;
        items.addAll(page);
        cursor = page.last.cursor;
        if (page.length < 500) break;
      }
      final dir = await getTemporaryDirectory();
      final cal = BusinessCalendar(rolloverHour: hour);
      final name =
          'khata-${cal.businessDateOf(r.start)}_${cal.businessDateOf(r.end.subtract(const Duration(seconds: 1)))}.csv';
      final file = File('${dir.path}/$name')
        ..writeAsStringSync(TransactionCsv.build(items.reversed));
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: l10n.repTitle),
      );
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.repExportFailed)));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(balancesProvider, (_, _) => _load());
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final labels = DateLabels(
      languageCode: prefs.languageCode,
      digits: prefs.digits,
    );
    final hour = ref.watch(dayRolloverHourProvider).value ?? 4;
    final range = _range(hour);
    final d = _data;

    final periodLabel = _period == _Period.week
        ? l10n.repStatementPeriod(
            labels.shortDay(range.start.add(const Duration(hours: 12))),
            labels.shortDay(range.end.subtract(const Duration(hours: 12))),
          )
        : labels.month(range.start.add(const Duration(days: 14)));

    Widget stat(String label, String value, {Color? color}) => SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(color: color),
          ),
        ],
      ),
    );

    String providerName(String id) =>
        ProviderCatalog.byId(id)?.name(prefs.languageCode) ?? id;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.repTitle),
        actions: [
          IconButton(
            tooltip: l10n.repExportCsv,
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _exporting ? null : _exportCsv,
          ),
        ],
      ),
      body: d == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<_Period>(
                  segments: [
                    ButtonSegment(
                      value: _Period.week,
                      label: Text(l10n.repWeek),
                    ),
                    ButtonSegment(
                      value: _Period.month,
                      label: Text(l10n.repMonth),
                    ),
                  ],
                  selected: {_period},
                  onSelectionChanged: (s) {
                    _period = s.first;
                    _offset = 0;
                    _load();
                  },
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: l10n.repPrev,
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        _offset--;
                        _load();
                      },
                    ),
                    Expanded(
                      child: Text(
                        periodLabel,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.repNext,
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _offset >= 0
                          ? null
                          : () {
                              _offset++;
                              _load();
                            },
                    ),
                  ],
                ),
                if (d.summary.count == 0)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(l10n.repNoData)),
                  )
                else ...[
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      stat(
                        l10n.sumEntries,
                        prefs.digits.localize('${d.summary.count}'),
                      ),
                      stat(
                        l10n.sumCashInVolume,
                        money.format(d.summary.cashInVolume),
                      ),
                      stat(
                        l10n.sumCashOutVolume,
                        money.format(d.summary.cashOutVolume),
                      ),
                      stat(
                        l10n.sumCommission,
                        money.format(d.summary.commission),
                      ),
                      stat(
                        l10n.sumMargin,
                        money.format(d.summary.flexiloadMargin),
                      ),
                      stat(l10n.sumExpenses, money.format(d.summary.expenses)),
                      stat(
                        l10n.sumNet,
                        money.format(d.summary.netProfit),
                        color: d.summary.netProfit.isNegative
                            ? tokens.cashOut
                            : tokens.cashIn,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.repNetPerDay, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SignedBarChart(
                    values: [
                      for (final p in d.summary.daily) p.net.paisa / 100,
                    ],
                    positive: tokens.cashIn,
                    negative: tokens.cashOut,
                    semanticsLabel: l10n.repNetPerDay,
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.repByType, style: theme.textTheme.titleMedium),
                  for (final e in d.summary.perType.entries)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(transactionTypeLabel(l10n, e.key)),
                      subtitle: Text(
                        '${prefs.digits.localize('${e.value.count}')} · '
                        '${money.format(e.value.volume)}',
                      ),
                      trailing: e.value.commission.isZero
                          ? null
                          : Text(money.format(e.value.commission)),
                    ),
                ],
                const Divider(height: 40),
                Text(l10n.insTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                if (!d.insights.hasEnoughData)
                  Text(l10n.insNotEnough)
                else ...[
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      stat(
                        l10n.insAvgSize,
                        money.format(d.insights.averageSize),
                      ),
                      if (d.insights.busiestHour case final h?)
                        stat(
                          l10n.insBusiestHour,
                          _hourRange(prefs.digits.localize, h.hour),
                        ),
                      if (d.insights.mostProfitableHour case final h?)
                        stat(
                          l10n.insBestHour,
                          _hourRange(prefs.digits.localize, h.hour),
                        ),
                      if (d.insights.bestWeekday case final w?)
                        stat(
                          l10n.insBestWeekday,
                          _weekdayName(l10n, w.weekday),
                        ),
                    ],
                  ),
                  if (d.insights.bestWeekday case final w?)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l10n.insPerDay(money.format(w.profitPerDay)),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(l10n.insHourChart, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  SignedBarChart(
                    values: [
                      for (final h in d.insights.hours) h.count.toDouble(),
                    ],
                    positive: theme.colorScheme.primary,
                    negative: tokens.cashOut,
                    height: 90,
                    semanticsLabel: l10n.insHourChart,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final h in const [0, 6, 12, 18, 23])
                        Text(
                          prefs.digits.localize('$h'),
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.insWeekdayChart, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  SignedBarChart(
                    values: [
                      for (final w in d.insights.weekdays)
                        w.profitPerDay.paisa / 100,
                    ],
                    positive: tokens.cashIn,
                    negative: tokens.cashOut,
                    height: 90,
                    semanticsLabel: l10n.insWeekdayChart,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (var wd = 1; wd <= 7; wd++)
                        Text(
                          _weekdayShort(l10n, wd),
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.insByType, style: theme.textTheme.titleSmall),
                  for (final t in d.insights.byType)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(transactionTypeLabel(l10n, t.type)),
                      subtitle: Text(
                        l10n.insEntries(prefs.digits.localize('${t.count}')),
                      ),
                      trailing: Text(money.format(t.average)),
                    ),
                ],
                const Divider(height: 40),
                Text(
                  l10n.repCommissionTitle,
                  style: theme.textTheme.titleMedium,
                ),
                if (d.commission.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l10n.repNoData),
                  ),
                for (final c in d.commission)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            providerName(c.provider),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              stat(l10n.repExpected, money.format(c.expected)),
                              stat(l10n.repReceived, money.format(c.received)),
                              stat(
                                l10n.repPending,
                                money.format(c.pending),
                                color: c.pending.isPositive
                                    ? tokens.warning
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_card_outlined),
                  label: Text(l10n.repRecordCommission),
                  onPressed: () async {
                    await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => const EntryScreen(
                          kind: EntryKind.commissionReceived,
                        ),
                      ),
                    );
                    if (mounted) await _load();
                  },
                ),
                const Divider(height: 40),
                Text(l10n.repVarianceTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(l10n.repVarianceHint, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      key: const ValueKey('variance-all'),
                      label: Text(l10n.histAllAccounts),
                      selected: _varianceAccountId == null,
                      onSelected: (_) {
                        _varianceAccountId = null;
                        _load();
                      },
                    ),
                    for (final a in d.varianceByAccount)
                      ChoiceChip(
                        key: ValueKey('variance-${a.accountId}'),
                        label: Text(a.label),
                        selected: _varianceAccountId == a.accountId,
                        onSelected: (_) {
                          _varianceAccountId = a.accountId;
                          _load();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (d.variance.isEmpty)
                  Text(l10n.repVarianceNone)
                else
                  SignedBarChart(
                    values: [
                      for (final p in d.variance) p.variance.paisa / 100,
                    ],
                    xLabels: [
                      for (final p in d.variance)
                        labels.shortDay(_dateOf(p.businessDate)),
                    ],
                    positive: tokens.warning,
                    negative: tokens.cashOut,
                    height: 150,
                    semanticsLabel: l10n.repVarianceTitle,
                  ),
                if (d.variance.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      d.variance
                          .map(
                            (p) => p.variance.isZero
                                ? null
                                : '${labels.shortDay(_dateOf(p.businessDate))}: '
                                      '${money.format(p.variance)}',
                          )
                          .whereType<String>()
                          .toList()
                          .reversed
                          .take(5)
                          .join('   '),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                if (d.varianceByAccount.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.repVarianceByAccount,
                    style: theme.textTheme.titleSmall,
                  ),
                  for (final a in d.varianceByAccount)
                    ListTile(
                      key: ValueKey('variance-row-${a.accountId}'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(a.label),
                      subtitle: Text(
                        a.daysWithDifference == 0
                            ? l10n.repVarianceAllGood
                            : [
                                if (!a.shortage.isZero)
                                  l10n.repVarianceShortOver(
                                    money.format(a.shortage.abs()),
                                    prefs.digits.localize(
                                      '${a.daysWithDifference}',
                                    ),
                                  ),
                                if (!a.excess.isZero)
                                  l10n.repVarianceExcessOver(
                                    money.format(a.excess),
                                  ),
                              ].join(' · '),
                      ),
                      trailing: Text(
                        money.format(a.total),
                        style: TextStyle(
                          color: a.total.isNegative
                              ? tokens.cashOut
                              : (a.total.isZero ? null : tokens.warning),
                        ),
                      ),
                    ),
                ],
                if (d.varianceByWeekday.any((w) => w.closedDays > 0)) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.repVarianceByWeekday,
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    l10n.repVarianceWeekdayHint,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  SignedBarChart(
                    values: [
                      for (final w in d.varianceByWeekday)
                        w.averageNet.paisa / 100,
                    ],
                    xLabels: [
                      for (final w in d.varianceByWeekday)
                        _weekdayShort(l10n, w.weekday),
                    ],
                    positive: tokens.warning,
                    negative: tokens.cashOut,
                    height: 130,
                    semanticsLabel: l10n.repVarianceByWeekday,
                  ),
                  Builder(
                    builder: (context) {
                      WeekdayVariance? worst;
                      for (final w in d.varianceByWeekday) {
                        if (w.shortDays == 0) continue;
                        if (worst == null || w.shortage < worst.shortage) {
                          worst = w;
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          worst == null
                              ? l10n.repVarianceNoPattern
                              : l10n.repVarianceWorst(
                                  _weekdayName(l10n, worst.weekday),
                                  prefs.digits.localize('${worst.shortDays}'),
                                  prefs.digits.localize('${worst.closedDays}'),
                                ),
                          style: theme.textTheme.bodyLarge,
                        ),
                      );
                    },
                  ),
                ],
                if (d.operators.isNotEmpty) ...[
                  const Divider(height: 40),
                  Text(
                    l10n.shiftOperatorVariance,
                    style: theme.textTheme.titleMedium,
                  ),
                  for (final o in d.operators)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.badge_outlined),
                      title: Text(
                        o.userId == kOwnerUserId
                            ? l10n.roleOwner
                            : (ref.watch(userNamesProvider)[o.userId] ?? ''),
                      ),
                      subtitle: Text(
                        '${prefs.digits.localize('${o.shifts}')} '
                        '${l10n.shiftRecent.toLowerCase()}',
                      ),
                      trailing: Text(
                        o.shortage.isZero
                            ? l10n.cdMatches
                            : l10n.shiftShortage(
                                money.format(o.shortage.abs()),
                              ),
                        style: TextStyle(
                          color: o.shortage.isZero ? null : tokens.warning,
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.file_download_outlined),
                  label: Text(
                    _exporting ? l10n.repExporting : l10n.repExportCsv,
                  ),
                  onPressed: _exporting ? null : _exportCsv,
                ),
              ],
            ),
    );
  }
}

String _hourRange(String Function(String) localize, int hour) {
  String hh(int h) =>
      '${localize((h % 24).toString().padLeft(2, '0'))}:'
      '${localize('00')}';
  return '${hh(hour)}–${hh(hour + 1)}';
}

String _weekdayName(AppLocalizations l10n, int wd) => [
  l10n.wdMon,
  l10n.wdTue,
  l10n.wdWed,
  l10n.wdThu,
  l10n.wdFri,
  l10n.wdSat,
  l10n.wdSun,
][wd - 1];

String _weekdayShort(AppLocalizations l10n, int wd) => [
  l10n.wdMonShort,
  l10n.wdTueShort,
  l10n.wdWedShort,
  l10n.wdThuShort,
  l10n.wdFriShort,
  l10n.wdSatShort,
  l10n.wdSunShort,
][wd - 1];

/// A business date as an instant that falls on that date in Dhaka.
DateTime _dateOf(String businessDate) {
  final p = businessDate.split('-').map(int.parse).toList();
  return DateTime.utc(p[0], p[1], p[2], 6);
}
