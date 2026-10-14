import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../l10n/gen/app_localizations.dart';
import 'day_close_service.dart';
import 'reconciliation_engine.dart';

const noteDenominations = [1000, 500, 200, 100, 50, 20, 10, 5, 2, 1];

/// Counts notes by denomination and returns the total in taka (or null).
Future<Money?> showCashCounter(
  BuildContext context, {
  required DigitFormatter digits,
}) {
  return showModalBottomSheet<Money>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _CashCounterSheet(digits: digits),
  );
}

class _CashCounterSheet extends StatefulWidget {
  const _CashCounterSheet({required this.digits});

  final DigitFormatter digits;

  @override
  State<_CashCounterSheet> createState() => _CashCounterSheetState();
}

class _CashCounterSheetState extends State<_CashCounterSheet> {
  final Map<int, TextEditingController> _counts = {
    for (final d in noteDenominations) d: TextEditingController(),
  };
  final TextEditingController _coins = TextEditingController();

  @override
  void dispose() {
    for (final c in _counts.values) {
      c.dispose();
    }
    _coins.dispose();
    super.dispose();
  }

  int _int(String t) => int.tryParse(DigitFormatter.toLatin(t).trim()) ?? 0;

  int get _total {
    var sum = _int(_coins.text);
    for (final e in _counts.entries) {
      sum += e.key * _int(e.value.text);
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = MoneyFormatter(digits: widget.digits);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.cdCashCounterTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Caprasimo',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final d in noteDenominations)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.fromLTRB(18, 4, 6, 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 78,
                            child: Text(
                              '৳ ${widget.digits.localize('$d')}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              fmt.format(
                                Money.taka(d * _int(_counts[d]!.text)),
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(LucideIcons.minus),
                            onPressed: () => setState(() {
                              final n = _int(_counts[d]!.text);
                              _counts[d]!.text = n > 0 ? '${n - 1}' : '';
                            }),
                          ),
                          SizedBox(
                            width: 52,
                            child: TextField(
                              key: ValueKey('count-$d'),
                              controller: _counts[d],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: '0',
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: theme.colorScheme.onSecondary,
                            ),
                            icon: const Icon(LucideIcons.plus),
                            onPressed: () => setState(() {
                              _counts[d]!.text =
                                  '${_int(_counts[d]!.text) + 1}';
                            }),
                          ),
                        ],
                      ),
                    ),
                  TextField(
                    key: const ValueKey('count-coins'),
                    controller: _coins,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.cdCoins,
                      prefixText: '৳ ',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    l10n.cdCounterTotal,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    fmt.format(Money.taka(_total)),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, Money.taka(_total)),
                  child: Text(l10n.cdCounterUse),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String reasonLabel(AppLocalizations l10n, AdjustmentReason r) => switch (r) {
  AdjustmentReason.shortage => l10n.cdReasonShortage,
  AdjustmentReason.excess => l10n.cdReasonExcess,
  AdjustmentReason.providerCharge => l10n.cdReasonProvider,
  AdjustmentReason.countingError => l10n.cdReasonCounting,
  AdjustmentReason.tolerance => l10n.cdReasonTolerance,
  AdjustmentReason.other => l10n.cdReasonOther,
};

/// Human text for a suggestion, in the active language.
String suggestionText(
  AppLocalizations l10n,
  Suggestion s, {
  required MoneyFormatter money,
  required String Function(String accountId) accountLabel,
}) {
  final amount = money.format(Money.paisa(s.amountPaisa ?? 0));
  switch (s.kind) {
    case SuggestionKind.sameAmountEntry:
      return s.sameDirection
          ? l10n.sugSameSame(amount)
          : l10n.sugSameOpposite(amount);
    case SuggestionKind.flippedDirection:
      return l10n.sugFlipped(amount);
    case SuggestionKind.amountRelation:
      return s.entryIsDouble
          ? l10n.sugEntryDouble(amount)
          : l10n.sugGapDouble(amount);
    case SuggestionKind.duplicateEntries:
      return l10n.sugDuplicate(amount);
    case SuggestionKind.digitTransposition:
      return l10n.sugTranspose(
        amount,
        money.format(Money.paisa(s.altAmountPaisa ?? 0)),
      );
    case SuggestionKind.crossAccount:
      return l10n.sugCross(accountLabel(s.otherAccountId ?? ''));
  }
}
