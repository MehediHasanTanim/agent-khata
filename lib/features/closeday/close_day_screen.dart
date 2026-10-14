import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/i18n/date_labels.dart';
import '../../core/i18n/digit_formatter.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/khata_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../entry/entry_screen.dart';
import '../history/transaction_detail_screen.dart';
import 'close_day_widgets.dart';
import 'daily_summary_screen.dart';
import 'day_close_service.dart';
import 'reconciliation_engine.dart';

/// Guided day close: count, review the differences (with "find the gap"
/// hints), give reasons, close. Replaces itself with the daily summary.
class CloseDayScreen extends ConsumerStatefulWidget {
  const CloseDayScreen({super.key, required this.businessDate});

  final String businessDate;

  @override
  ConsumerState<CloseDayScreen> createState() => _CloseDayScreenState();
}

class _CloseDayScreenState extends ConsumerState<CloseDayScreen> {
  CloseDayPreview? _preview;
  final Map<String, TextEditingController> _actual = {};
  final Map<String, AdjustmentReason?> _reason = {};
  final Map<String, TextEditingController> _note = {};
  bool _review = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [..._actual.values, ..._note.values]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final p = await ref
        .read(dayCloseServiceProvider)
        .preview(widget.businessDate);
    if (!mounted) return;
    setState(() {
      _preview = p;
      for (final a in p.accounts) {
        _actual.putIfAbsent(a.account.id, TextEditingController.new);
        _note.putIfAbsent(a.account.id, TextEditingController.new);
      }
    });
  }

  Money? _parseActual(String id, Money expected) {
    final t = DigitFormatter.toLatin(_actual[id]!.text)
        .replaceAll(',', '')
        .trim();
    if (t.isEmpty) return expected;
    return Money.tryParse(t);
  }

  bool get _allValid => _preview!.accounts.every(
    (a) => _parseActual(a.account.id, a.expected) != null,
  );

  Map<String, Money> _variances() => {
    for (final a in _preview!.accounts)
      a.account.id:
          (_parseActual(a.account.id, a.expected) ?? a.expected) - a.expected,
  };

  Future<void> _addMissing() async {
    final l10n = AppLocalizations.of(context);
    final kind = await showModalBottomSheet<EntryKind>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (k, label) in [
              (EntryKind.cashOut, l10n.txnCashOut),
              (EntryKind.cashIn, l10n.txnCashIn),
              (EntryKind.flexiload, l10n.txnFlexiload),
              (EntryKind.floatPurchase, l10n.txnFloatPurchase),
              (EntryKind.expense, l10n.txnExpense),
            ])
              ListTile(title: Text(label), onTap: () => Navigator.pop(ctx, k)),
          ],
        ),
      ),
    );
    if (kind == null || !mounted) return;
    await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => EntryScreen(kind: kind)));
    if (mounted) await _load();
  }

  Future<void> _close() async {
    final l10n = AppLocalizations.of(context);
    final p = _preview!;
    final prefs = ref.read(preferencesProvider);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final actuals = {
        for (final a in p.accounts)
          a.account.id: _parseActual(a.account.id, a.expected)!,
      };
      final resolutions = <String, VarianceResolution>{
        for (final a in p.accounts)
          if (_reason[a.account.id] != null)
            a.account.id: VarianceResolution(
              _reason[a.account.id]!,
              text: _note[a.account.id]!.text,
            ),
      };
      await ref
          .read(dayCloseServiceProvider)
          .close(
            businessDate: p.businessDate,
            actuals: actuals,
            resolutions: resolutions,
            toleranceTaka: prefs.varianceToleranceTaka,
            userId: currentUserId(ref),
          );
      if (!mounted) return;
      if (resolutions.isEmpty) {
        await showSuccessPop(context, l10n.cdClosedOk);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.cdClosedOk)));
      }
      if (!mounted) return;
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute(
          builder: (_) => DailySummaryScreen(
            businessDate: p.businessDate,
            interstitialOnExit: true,
          ),
        ),
      );
    } on MissingVarianceReason {
      setState(() {
        _busy = false;
        _error = l10n.cdMissingReason;
      });
    } on Object {
      setState(() {
        _busy = false;
        _error = l10n.cdFailed;
      });
    }
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
    final p = _preview;

    if (p == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.cdTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final parts = p.businessDate.split('-').map(int.parse).toList();
    final dateText = labels.day(DateTime.utc(parts[0], parts[1], parts[2], 6));
    final tolerance = Money.taka(prefs.varianceToleranceTaka);
    final variances = _variances();
    final labelById = {
      for (final a in p.accounts) a.account.id: a.account.label,
    };
    final suggestions = const ReconciliationEngine().analyze(
      variancePaisa: {for (final e in variances.entries) e.key: e.value.paisa},
      entries: p.entries,
    );

    bool needsReason(Money v) => !v.isZero && v.abs() > tolerance;
    final reasonsComplete = p.accounts.every((a) {
      final v = variances[a.account.id]!;
      return !needsReason(v) || _reason[a.account.id] != null;
    });

    final scheme = theme.colorScheme;

    Widget stepBar() => Row(
      children: [
        for (var i = 0; i < 2; i++)
          Expanded(
            child: Container(
              height: 8,
              margin: EdgeInsets.only(right: i == 0 ? 6 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: (i == 0 || _review)
                    ? scheme.primary
                    : scheme.tertiaryContainer,
              ),
            ),
          ),
      ],
    );

    Widget surfaceCard(Widget child) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );

    Widget pill(
      String label, {
      required bool selected,
      required VoidCallback onTap,
      Color? selectedColor,
    }) => Material(
      color: selected
          ? (selectedColor ?? scheme.primary)
          : scheme.tertiaryContainer,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: selected ? scheme.onPrimary : scheme.onSurface,
            ),
          ),
        ),
      ),
    );

    Widget countStep() => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        stepBar(),
        const SizedBox(height: 14),
        Text(
          dateText,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(l10n.cdIntro, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        for (final a in p.accounts)
          surfaceCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.account.kind == AccountKind.cash
                      ? l10n.homeCash
                      : a.account.label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${l10n.cdExpected}: ${money.format(a.expected)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: ValueKey('actual-${a.account.id}'),
                  controller: _actual[a.account.id],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.cdActual,
                    helperText: l10n.cdBlankHint,
                    prefixText: '৳ ',
                    errorText: _parseActual(a.account.id, a.expected) == null
                        ? l10n.amountInvalid
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (a.account.kind == AccountKind.cash) ...[
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    icon: const Icon(LucideIcons.calculator),
                    label: Text(l10n.cdCashCounter),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      backgroundColor: scheme.secondaryContainer,
                      foregroundColor: scheme.onSecondaryContainer,
                    ),
                    onPressed: () async {
                      final total = await showCashCounter(
                        context,
                        digits: prefs.digits,
                      );
                      if (total != null) {
                        setState(
                          () => _actual[a.account.id]!.text =
                              '${total.wholeTaka}',
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
      ],
    );

    Widget reviewStep() => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        stepBar(),
        const SizedBox(height: 14),
        for (final a in p.accounts)
          Builder(
            builder: (context) {
              final v = variances[a.account.id]!;
              final mine = suggestions
                  .where((s) => s.accountId == a.account.id)
                  .toList();
              final ok = v.isZero;
              final within = !ok && !needsReason(v);
              final chipBg = ok
                  ? scheme.secondaryContainer
                  : scheme.primaryContainer;
              final chipFg = ok
                  ? scheme.onSecondaryContainer
                  : scheme.onPrimaryContainer;
              return surfaceCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.account.kind == AccountKind.cash
                                ? l10n.homeCash
                                : a.account.label,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                ok
                                    ? LucideIcons.check
                                    : LucideIcons.circleAlert,
                                size: 18,
                                color: chipFg,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ok
                                    ? l10n.cdMatches
                                    : v.isNegative
                                    ? l10n.cdShort(money.format(v.abs()))
                                    : l10n.cdExcess(money.format(v)),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: chipFg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!ok && !within) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final r in AdjustmentReason.values)
                            if (r != AdjustmentReason.tolerance)
                              pill(
                                reasonLabel(l10n, r),
                                selected: _reason[a.account.id] == r,
                                onTap: () =>
                                    setState(() => _reason[a.account.id] = r),
                              ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _note[a.account.id],
                        decoration: InputDecoration(
                          labelText: l10n.cdReasonNote,
                        ),
                      ),
                    ],
                    if (within)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(l10n.cdReasonTolerance),
                      ),
                    if (!ok && mine.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.cdFindGap,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: context.tokens.cashOut,
                              ),
                            ),
                            const SizedBox(height: 6),
                            for (final s in mine)
                              InkWell(
                                onTap: s.txnId == null
                                    ? null
                                    : () async {
                                        await Navigator.of(context).push<bool>(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                TransactionDetailScreen(
                                                  txnId: s.txnId!,
                                                ),
                                          ),
                                        );
                                        if (mounted) await _load();
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '•  ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: context.tokens.cashOut,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          suggestionText(
                                            l10n,
                                            s,
                                            money: money,
                                            accountLabel: (id) =>
                                                labelById[id] ?? '',
                                          ),
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),
                            FilledButton.icon(
                              icon: const Icon(LucideIcons.plus),
                              label: Text(l10n.cdAddMissing),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 44),
                                backgroundColor: scheme.secondaryContainer,
                                foregroundColor: scheme.onSecondaryContainer,
                              ),
                              onPressed: _addMissing,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        Text(
          l10n.cdTolerance(money.format(tolerance)),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cdTitle),
        leading: BackButton(
          onPressed: () {
            if (_review) {
              setState(() => _review = false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _review ? reviewStep() : countStep()),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: _review
                    ? Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: scheme.tertiaryContainer,
                                foregroundColor: scheme.onSurface,
                              ),
                              onPressed: () => setState(() => _review = false),
                              child: Text('‹ ${l10n.back}'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              key: const ValueKey('close-day'),
                              style: FilledButton.styleFrom(
                                backgroundColor: scheme.secondary,
                                foregroundColor: scheme.onSecondary,
                              ),
                              onPressed: _busy || !reasonsComplete
                                  ? null
                                  : _close,
                              child: Text(l10n.cdClose),
                            ),
                          ),
                        ],
                      )
                    : FilledButton(
                        key: const ValueKey('review'),
                        onPressed: _allValid
                            ? () => setState(() => _review = true)
                            : null,
                        child: Text(l10n.cdReview),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
