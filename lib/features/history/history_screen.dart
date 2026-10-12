import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/date_labels.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/utils/business_calendar.dart';
import '../../l10n/gen/app_localizations.dart';
import '../transactions/history_filter.dart';
import '../transactions/history_queries.dart';
import 'history_widgets.dart';
import 'transaction_detail_screen.dart';

enum _Period { today, yesterday, week, month, all }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  static const _pageSize = 50;

  _Period _period = _Period.today;
  TransactionType? _type;
  String? _accountId;
  String _query = '';
  final TextEditingController _search = TextEditingController();

  final List<HistoryItem> _items = [];
  HistoryTotals _totals = const HistoryTotals();
  bool _loading = false;
  bool _hasMore = true;
  int _generation = 0;
  int _rollover = 4;

  @override
  void initState() {
    super.initState();
    Future.microtask(_init);
  }

  Future<void> _init() async {
    _rollover = await ref.read(dayRolloverHourProvider.future);
    await _reload();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  HistoryFilter get _filter {
    final cal = BusinessCalendar(rolloverHour: _rollover);
    final now = DateTime.now().toUtc();
    DateTime? from;
    DateTime? to;
    switch (_period) {
      case _Period.today:
        final r = cal.dayRange(now);
        from = r.start;
        to = r.end;
      case _Period.yesterday:
        final r = cal.dayRange(now.subtract(const Duration(days: 1)));
        from = r.start;
        to = r.end;
      case _Period.week:
        from = cal.dayRange(now.subtract(const Duration(days: 6))).start;
        to = cal.dayRange(now).end;
      case _Period.month:
        final r = cal.monthRange(now);
        from = r.start;
        to = r.end;
      case _Period.all:
        break;
    }
    return HistoryFilter(
      from: from,
      to: to,
      types: _type == null ? const {} : {_type!},
      accountId: _accountId,
      query: _query,
    );
  }

  Future<void> _reload() async {
    final gen = ++_generation;
    setState(() {
      _items.clear();
      _hasMore = true;
      _loading = true;
    });
    final q = ref.read(historyQueriesProvider);
    final filter = _filter;
    final page = await q.page(filter, limit: _pageSize);
    final totals = await q.totals(filter);
    if (!mounted || gen != _generation) return;
    setState(() {
      _items.addAll(page);
      _totals = totals;
      _hasMore = page.length == _pageSize;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore || _items.isEmpty) return;
    final gen = _generation;
    setState(() => _loading = true);
    final page = await ref
        .read(historyQueriesProvider)
        .page(_filter, after: _items.last.cursor, limit: _pageSize);
    if (!mounted || gen != _generation) return;
    setState(() {
      _items.addAll(page);
      _hasMore = page.length == _pageSize;
      _loading = false;
    });
  }

  Future<void> _open(HistoryItem item) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(txnId: item.id),
      ),
    );
    if (changed == true) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    // Any ledger change (new, undone or voided entry) refreshes the list.
    ref.listen(balancesProvider, (_, _) {
      if (_rollover >= 0 && mounted) _reload();
    });
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final labels = DateLabels(
      languageCode: prefs.languageCode,
      digits: prefs.digits,
    );
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final cal = BusinessCalendar(rolloverHour: _rollover);

    String periodLabel(_Period p) => switch (p) {
      _Period.today => l10n.histToday,
      _Period.yesterday => l10n.histYesterday,
      _Period.week => l10n.histWeek,
      _Period.month => l10n.histMonth,
      _Period.all => l10n.histAll,
    };

    final typeFilters = <TransactionType?>[
      null,
      TransactionType.cashOut,
      TransactionType.cashIn,
      TransactionType.flexiload,
      TransactionType.floatPurchase,
      TransactionType.expense,
    ];

    // Group by business date for day headers.
    final children = <Widget>[];
    String? lastDate;
    for (final item in _items) {
      final date = cal.businessDateOf(item.occurredAt);
      if (date != lastDate) {
        lastDate = date;
        final isToday = date == cal.businessDateOf(DateTime.now().toUtc());
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              isToday
                  ? '${l10n.histToday} · ${labels.day(item.occurredAt)}'
                  : labels.day(item.occurredAt),
              style: theme.textTheme.titleMedium,
            ),
          ),
        );
      }
      children.add(
        _HistoryTile(
          item: item,
          money: money,
          labels: labels,
          onTap: () => _open(item),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navHistory)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.histSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          _query = '';
                          _reload();
                        },
                      ),
              ),
              onSubmitted: (v) {
                _query = v;
                _reload();
              },
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final p in _Period.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: ValueKey('period-${p.name}'),
                      label: Text(periodLabel(p)),
                      selected: _period == p,
                      onSelected: (_) {
                        _period = p;
                        _reload();
                      },
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final t in typeFilters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      key: ValueKey('type-${t?.name ?? 'all'}'),
                      label: Text(
                        t == null ? l10n.histAll : _typeText(l10n, t),
                      ),
                      selected: _type == t,
                      onSelected: (_) {
                        _type = t;
                        _reload();
                      },
                    ),
                  ),
                PopupMenuButton<String?>(
                  tooltip: l10n.histAccountFilter,
                  onSelected: (v) {
                    _accountId = v == '' ? null : v;
                    _reload();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: '', child: Text(l10n.histAllAccounts)),
                    for (final a in accounts)
                      if (a.kind != AccountKind.external)
                        PopupMenuItem(value: a.id, child: Text(a.label)),
                  ],
                  child: Chip(
                    avatar: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                    ),
                    label: Text(
                      accounts
                              .where((a) => a.id == _accountId)
                              .map((a) => a.label)
                              .firstOrNull ??
                          l10n.histAccountFilter,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  l10n.histCount(prefs.digits.localize('${_totals.count}')),
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  l10n.histTotal(money.format(_totals.amount)),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty && !_loading
                ? Center(child: Text(l10n.histEmpty))
                : ListView(
                    children: [
                      ...children,
                      if (_hasMore && _items.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: OutlinedButton(
                            onPressed: _loading ? null : _loadMore,
                            child: Text(l10n.histLoadMore),
                          ),
                        ),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _typeText(AppLocalizations l10n, TransactionType t) => switch (t) {
    TransactionType.cashOut => l10n.txnCashOut,
    TransactionType.cashIn => l10n.txnCashIn,
    TransactionType.flexiload => l10n.txnFlexiload,
    TransactionType.floatPurchase => l10n.txnFloatPurchase,
    TransactionType.expense => l10n.txnExpense,
    _ => l10n.txnOther,
  };
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.item,
    required this.money,
    required this.labels,
    required this.onTap,
  });

  final HistoryItem item;
  final MoneyFormatter money;
  final DateLabels labels;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final strike = item.isVoid
        ? const TextStyle(decoration: TextDecoration.lineThrough)
        : null;
    final sub = [
      labels.time(item.occurredAt),
      if (item.accountLabel != null) item.accountLabel!,
      if (item.customerName != null) item.customerName!,
      if (item.customerNumber != null) item.customerNumber!,
    ].join(' · ');
    return ListTile(
      onTap: onTap,
      leading: Icon(
        iconFor(item.type),
        color: item.isVoid ? theme.disabledColor : colorFor(context, item.type),
      ),
      title: Row(
        children: [
          Flexible(
            child: DefaultTextStyle.merge(
              style: strike,
              child: TypeLabel(item.type),
            ),
          ),
          if (item.isVoid) ...[
            const SizedBox(width: 8),
            Text(l10n.labelVoided, style: theme.textTheme.bodyMedium),
          ],
          if (item.isLocked) ...[
            const SizedBox(width: 8),
            const Icon(Icons.lock_outline, size: 16),
          ],
        ],
      ),
      subtitle: Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(
        money.format(item.amount),
        style: theme.textTheme.titleMedium?.merge(strike),
      ),
    );
  }
}
