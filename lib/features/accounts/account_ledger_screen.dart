import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/date_labels.dart';
import '../../core/ledger/account.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import '../commission/commission_rates_screen.dart' show transactionTypeLabel;
import '../history/transaction_detail_screen.dart';
import '../transactions/history_queries.dart';
import 'adjustment_screen.dart';

enum _Range { week, month, all }

/// Paper-style statement for one account: date, description, in, out and a
/// running balance.
class AccountLedgerScreen extends ConsumerStatefulWidget {
  const AccountLedgerScreen({super.key, required this.account});

  final Account account;

  @override
  ConsumerState<AccountLedgerScreen> createState() =>
      _AccountLedgerScreenState();
}

class _AccountLedgerScreenState extends ConsumerState<AccountLedgerScreen> {
  static const _pageSize = 100;

  _Range _range = _Range.month;
  final List<LedgerLine> _lines = [];
  bool _loading = false;
  bool _hasMore = true;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
  }

  ({DateTime? from, DateTime? to}) get _bounds {
    final now = DateTime.now().toUtc();
    return switch (_range) {
      _Range.week => (from: now.subtract(const Duration(days: 7)), to: null),
      _Range.month => (from: now.subtract(const Duration(days: 30)), to: null),
      _Range.all => (from: null, to: null),
    };
  }

  Future<void> _reload() async {
    final gen = ++_generation;
    setState(() {
      _lines.clear();
      _hasMore = true;
      _loading = true;
    });
    final page = await _fetch(0);
    if (!mounted || gen != _generation) return;
    setState(() {
      _lines.addAll(page);
      _hasMore = page.length == _pageSize;
      _loading = false;
    });
  }

  Future<List<LedgerLine>> _fetch(int offset) {
    final b = _bounds;
    return ref
        .read(accountLedgerQueriesProvider)
        .page(
          widget.account.id,
          from: b.from,
          to: b.to,
          limit: _pageSize,
          offset: offset,
        );
  }

  Future<void> _more() async {
    if (_loading || !_hasMore) return;
    final gen = _generation;
    setState(() => _loading = true);
    final page = await _fetch(_lines.length);
    if (!mounted || gen != _generation) return;
    setState(() {
      _lines.addAll(page);
      _hasMore = page.length == _pageSize;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final fmt = MoneyFormatter(digits: prefs.digits, showSymbol: false);
    final money = MoneyFormatter(digits: prefs.digits);
    final labels = DateLabels(
      languageCode: prefs.languageCode,
      digits: prefs.digits,
    );
    final tokens = context.tokens;
    final balance =
        ref.watch(balancesProvider).value?[widget.account.id] ?? Money.zero;

    String rangeLabel(_Range r) => switch (r) {
      _Range.week => l10n.histWeek,
      _Range.month => l10n.histMonth,
      _Range.all => l10n.histAll,
    };

    Widget head(String t, {TextAlign align = TextAlign.end}) => Expanded(
      child: Text(t, textAlign: align, style: theme.textTheme.labelLarge),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ledgerTitle(widget.account.label)),
        actions: [
          IconButton(
            tooltip: l10n.ledgerAdjust,
            icon: const Icon(Icons.tune),
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => AdjustmentScreen(account: widget.account),
                ),
              );
              if (mounted) await _reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(l10n.ledgerBalance, style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  money.format(balance),
                  style: theme.textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children: [
                for (final r in _Range.values)
                  ChoiceChip(
                    label: Text(rangeLabel(r)),
                    selected: _range == r,
                    onSelected: (_) {
                      _range = r;
                      _reload();
                    },
                  ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                head(l10n.ledgerDate, align: TextAlign.start),
                head(l10n.ledgerIn),
                head(l10n.ledgerOut),
                head(l10n.ledgerBalance),
              ],
            ),
          ),
          const Divider(height: 8),
          Expanded(
            child: _lines.isEmpty && !_loading
                ? Center(child: Text(l10n.ledgerEmpty))
                : ListView(
                    children: [
                      for (final line in _lines)
                        InkWell(
                          onTap: () => Navigator.of(context)
                              .push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => TransactionDetailScreen(
                                    txnId: line.txnId,
                                  ),
                                ),
                              )
                              .then((changed) {
                                if (changed == true) _reload();
                              }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        labels.shortDay(line.occurredAt),
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Text(
                                        transactionTypeLabel(l10n, line.type),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              decoration: line.isVoid
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    line.delta.isPositive
                                        ? fmt.format(line.delta)
                                        : '',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(color: tokens.cashIn),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    line.delta.isNegative
                                        ? fmt.format(line.delta.abs())
                                        : '',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(color: tokens.cashOut),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    line.isVoid ? '' : fmt.format(line.balance),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_hasMore && _lines.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: OutlinedButton(
                            onPressed: _loading ? null : _more,
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
}
