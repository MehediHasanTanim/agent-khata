import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/ads/ad_widgets.dart';
import '../../core/i18n/date_labels.dart';
import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/security/roles.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/khata_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../commission/commission_rates_screen.dart' show transactionTypeLabel;
import '../history/transaction_detail_screen.dart';
import '../reports/statement_renderer.dart';
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

  /// Renders the visible period as a paper-style statement PDF and shares it.
  Future<void> _shareStatement() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final prefs = ref.read(preferencesProvider);
    final plain = MoneyFormatter(digits: prefs.digits, showSymbol: false);
    final labels = DateLabels(
      languageCode: prefs.languageCode,
      digits: prefs.digits,
    );
    try {
      final b = _bounds;
      final queries = ref.read(accountLedgerQueriesProvider);
      final all = <LedgerLine>[];
      var offset = 0;
      while (true) {
        final page = await queries.page(
          widget.account.id,
          from: b.from,
          to: b.to,
          limit: 500,
          offset: offset,
        );
        all.addAll(page);
        if (page.length < 500) break;
        offset += 500;
      }
      final chronological = all.reversed.toList();
      final rows = [
        for (final line in chronological)
          StatementRow(
            date:
                '${labels.shortDay(line.occurredAt)} '
                '${labels.time(line.occurredAt)}',
            description: [
              transactionTypeLabel(l10n, line.type),
              if (line.customerNumber != null) line.customerNumber!,
              if (line.note != null) line.note!,
            ].join(' · '),
            moneyIn: line.delta.isPositive ? plain.format(line.delta) : '',
            moneyOut: line.delta.isNegative
                ? plain.format(line.delta.abs())
                : '',
            balance: line.isVoid ? '' : plain.format(line.balance),
            isVoid: line.isVoid,
          ),
      ];
      final from = chronological.isEmpty
          ? DateTime.now()
          : chronological.first.occurredAt;
      final to = chronological.isEmpty
          ? DateTime.now()
          : chronological.last.occurredAt;
      final pngs = await const StatementRenderer().render(
        title: l10n.repStatementTitle(widget.account.label),
        subtitle: l10n.repStatementPeriod(labels.day(from), labels.day(to)),
        headers: [
          l10n.ledgerDate,
          l10n.ledgerDescription,
          l10n.ledgerIn,
          l10n.ledgerOut,
          l10n.ledgerBalance,
        ],
        rows: rows,
        footer: (n, total) => l10n.repPage(
          prefs.digits.localize('$n'),
          prefs.digits.localize('$total'),
        ),
      );
      final doc = pw.Document();
      for (final png in pngs) {
        final image = pw.MemoryImage(png);
        doc.addPage(
          pw.Page(
            margin: pw.EdgeInsets.zero,
            build: (_) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(image, fit: pw.BoxFit.fill),
            ),
          ),
        );
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/statement-${widget.account.id}.pdf')
        ..writeAsBytesSync(await doc.save());
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.sumShareFailed)));
    }
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

    final scheme = theme.colorScheme;
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final switchable = [
      for (final a in accounts)
        if (a.kind == AccountKind.cash ||
            a.kind == AccountKind.wallet ||
            a.kind == AccountKind.load)
          a,
    ];
    final session = ref.watch(sessionProvider);
    final canAdjust =
        session != null && Permissions.can(session, Permission.adjustBalance);

    Widget head(String t, {TextAlign align = TextAlign.end}) => Expanded(
      child: Text(
        t,
        textAlign: align,
        style: theme.textTheme.labelLarge?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    Widget pillButton(IconData icon, String label, VoidCallback onTap) =>
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 48),
              backgroundColor: scheme.tertiaryContainer,
              foregroundColor: scheme.onSurface,
            ),
            icon: Icon(icon),
            label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            onPressed: onTap,
          ),
        );

    return Scaffold(
      bottomNavigationBar: const AdFooter(),
      appBar: AppBar(title: Text(l10n.ledgerTitle(widget.account.label))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        children: [
          if (switchable.length > 1)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final a in switchable)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        key: ValueKey('ledger-tab-${a.id}'),
                        showCheckmark: false,
                        label: Text(
                          a.kind == AccountKind.cash ? l10n.homeCash : a.label,
                        ),
                        selected: a.id == widget.account.id,
                        onSelected: (_) {
                          if (a.id == widget.account.id) return;
                          Navigator.of(context).pushReplacement<void, void>(
                            MaterialPageRoute(
                              builder: (_) => AccountLedgerScreen(account: a),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          HeroCard(
            margin: const EdgeInsets.only(top: 4, bottom: 12),
            label: l10n.ledgerBalance,
            value: money.format(balance),
          ),
          PillSegmented<_Range>(
            value: _range,
            options: [for (final r in _Range.values) (r, rangeLabel(r))],
            onChanged: (r) {
              _range = r;
              _reload();
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (canAdjust) ...[
                pillButton(
                  LucideIcons.slidersHorizontal,
                  l10n.ledgerAdjust,
                  () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) =>
                            AdjustmentScreen(account: widget.account),
                      ),
                    );
                    if (mounted) await _reload();
                  },
                ),
                const SizedBox(width: 8),
              ],
              pillButton(
                LucideIcons.fileText,
                l10n.repStatementPdf,
                _shareStatement,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        l10n.ledgerDate,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    head(l10n.ledgerIn),
                    head(l10n.ledgerOut),
                    head(l10n.ledgerBalance),
                  ],
                ),
                const SizedBox(height: 4),
                if (_lines.isEmpty && !_loading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      l10n.ledgerEmpty,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                for (final line in _lines)
                  InkWell(
                    onTap: () => Navigator.of(context)
                        .push<bool>(
                          MaterialPageRoute(
                            builder: (_) =>
                                TransactionDetailScreen(txnId: line.txnId),
                          ),
                        )
                        .then((changed) {
                          if (changed == true) _reload();
                        }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: scheme.outlineVariant),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transactionTypeLabel(l10n, line.type),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    decoration: line.isVoid
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(
                                  labels.shortDay(line.occurredAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
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
                              style: TextStyle(
                                color: tokens.cashIn,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              line.delta.isNegative
                                  ? fmt.format(line.delta.abs())
                                  : '',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: tokens.cashOut,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              line.isVoid ? '' : fmt.format(line.balance),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: scheme.onSurface, width: 2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          l10n.ledgerBalance,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        money.format(balance),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_hasMore && _lines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton.tonal(
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
    );
  }
}
