import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import '../closeday/close_day_widgets.dart';
import '../closeday/day_close_service.dart';
import '../closeday/reconciliation_engine.dart';

/// Count the drawer and wallets at the end of a shift. Same flow as the day
/// close, but attributed to the operator and carrying forward to the next.
class ShiftHandoverScreen extends ConsumerStatefulWidget {
  const ShiftHandoverScreen({super.key});

  @override
  ConsumerState<ShiftHandoverScreen> createState() =>
      _ShiftHandoverScreenState();
}

class _ShiftHandoverScreenState extends ConsumerState<ShiftHandoverScreen> {
  List<({String accountId, String label, AccountKind kind, Money expected})>?
  _accounts;
  List<DayEntry> _entries = const [];
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
    final service = ref.read(shiftServiceProvider);
    final open = await service.currentOpen();
    final accounts = await service.expectedNow();
    final entries = open == null
        ? const <DayEntry>[]
        : await service.entriesOf(open.id);
    if (!mounted) return;
    setState(() {
      _accounts = accounts;
      _entries = entries;
      for (final a in accounts) {
        _actual.putIfAbsent(a.accountId, TextEditingController.new);
        _note.putIfAbsent(a.accountId, TextEditingController.new);
      }
    });
  }

  Money? _parse(String id, Money expected) {
    final t = DigitFormatter.toLatin(_actual[id]!.text)
        .replaceAll(',', '')
        .trim();
    if (t.isEmpty) return expected;
    return Money.tryParse(t);
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context);
    final accounts = _accounts!;
    final prefs = ref.read(preferencesProvider);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(shiftServiceProvider)
          .handover(
            actuals: {
              for (final a in accounts)
                a.accountId: _parse(a.accountId, a.expected)!,
            },
            resolutions: {
              for (final a in accounts)
                if (_reason[a.accountId] != null)
                  a.accountId: VarianceResolution(
                    _reason[a.accountId]!,
                    text: _note[a.accountId]!.text,
                  ),
            },
            toleranceTaka: prefs.varianceToleranceTaka,
            userId: currentUserId(ref),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.shiftDone)));
      Navigator.of(context).pop(true);
    } on MissingVarianceReason {
      setState(() {
        _busy = false;
        _error = l10n.reasonRequiredHere;
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
    final tokens = context.tokens;
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final accounts = _accounts;
    if (accounts == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.shiftHandoverTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final tolerance = Money.taka(prefs.varianceToleranceTaka);
    final labelOf = {for (final a in accounts) a.accountId: a.label};
    final variances = {
      for (final a in accounts)
        a.accountId:
            (_parse(a.accountId, a.expected) ?? a.expected) - a.expected,
    };
    final suggestions = const ReconciliationEngine().analyze(
      variancePaisa: {for (final e in variances.entries) e.key: e.value.paisa},
      entries: _entries,
    );
    bool needsReason(Money v) => !v.isZero && v.abs() > tolerance;
    final allValid = accounts.every(
      (a) => _parse(a.accountId, a.expected) != null,
    );
    final reasonsComplete = accounts.every(
      (a) =>
          !needsReason(variances[a.accountId]!) || _reason[a.accountId] != null,
    );

    Widget countStep() => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.shiftHandoverIntro, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        for (final a in accounts)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.kind == AccountKind.cash ? l10n.homeCash : a.label,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text('${l10n.cdExpected}: ${money.format(a.expected)}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: ValueKey('actual-${a.accountId}'),
                          controller: _actual[a.accountId],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.cdActual,
                            helperText: l10n.cdBlankHint,
                            prefixText: '৳ ',
                            errorText: _parse(a.accountId, a.expected) == null
                                ? l10n.amountInvalid
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      if (a.kind == AccountKind.cash) ...[
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: l10n.cdCashCounter,
                          icon: const Icon(Icons.calculate_outlined),
                          onPressed: () async {
                            final total = await showCashCounter(
                              context,
                              digits: prefs.digits,
                            );
                            if (total != null) {
                              setState(
                                () => _actual[a.accountId]!.text =
                                    '${total.wholeTaka}',
                              );
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    Widget reviewStep() => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final a in accounts)
          Builder(
            builder: (context) {
              final v = variances[a.accountId]!;
              final ok = v.isZero;
              final within = !ok && !needsReason(v);
              final mine = suggestions
                  .where((s) => s.accountId == a.accountId)
                  .toList();
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.kind == AccountKind.cash
                                  ? l10n.homeCash
                                  : a.label,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          Icon(
                            ok ? Icons.check_circle : Icons.error_outline,
                            color: ok ? tokens.cashIn : tokens.warning,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ok
                                ? l10n.cdMatches
                                : v.isNegative
                                ? l10n.cdShort(money.format(v.abs()))
                                : l10n.cdExcess(money.format(v)),
                          ),
                        ],
                      ),
                      if (!ok)
                        for (final s in mine)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.lightbulb_outline),
                            title: Text(
                              suggestionText(
                                l10n,
                                s,
                                money: money,
                                accountLabel: (id) => labelOf[id] ?? '',
                              ),
                            ),
                          ),
                      if (!ok && !within) ...[
                        DropdownButtonFormField<AdjustmentReason>(
                          key: ValueKey('reason-${a.accountId}'),
                          initialValue: _reason[a.accountId],
                          decoration: InputDecoration(labelText: l10n.cdReason),
                          items: [
                            for (final r in AdjustmentReason.values)
                              if (r != AdjustmentReason.tolerance)
                                DropdownMenuItem(
                                  value: r,
                                  child: Text(reasonLabel(l10n, r)),
                                ),
                          ],
                          onChanged: (r) =>
                              setState(() => _reason[a.accountId] = r),
                        ),
                        TextField(
                          controller: _note[a.accountId],
                          decoration: InputDecoration(
                            labelText: l10n.cdReasonNote,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        if (_error != null)
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shiftHandoverTitle),
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
                height: 56,
                child: _review
                    ? FilledButton(
                        key: const ValueKey('confirm-handover'),
                        onPressed: _busy || !reasonsComplete ? null : _confirm,
                        child: Text(l10n.shiftHandover),
                      )
                    : FilledButton(
                        key: const ValueKey('review-handover'),
                        onPressed: allValid
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
