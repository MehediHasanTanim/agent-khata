import 'package:flutter/material.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../core/money/money.dart';
import '../../l10n/gen/app_localizations.dart';
import 'commission_rule.dart';
import 'rate_codec.dart';

/// Editable text of one tier: "up to" amount (ASCII taka) and its rate.
class TierInput {
  TierInput({
    this.upTo = '',
    this.mode = CommissionMode.perThousand,
    this.value = '',
  });

  factory TierInput.from(CommissionTier t) => TierInput(
    upTo: t.upTo == null ? '' : '${t.upTo!.wholeTaka}',
    mode: t.mode,
    value: RateCodec.format(t.value),
  );

  String upTo;
  CommissionMode mode;
  String value;

  int? get valueParsed => RateCodec.parse(DigitFormatter.toLatin(value));

  Money? get upToParsed {
    final t = DigitFormatter.toLatin(upTo).replaceAll(',', '').trim();
    return t.isEmpty ? null : Money.tryParse(t);
  }
}

/// Editable (mode, value) pair, or a tier list, used by onboarding and the
/// rates screen.
class RateInput {
  RateInput({
    required this.mode,
    required int value,
    List<CommissionTier> tiers = const [],
  }) : text = RateCodec.format(value),
       tiers = [for (final t in tiers) TierInput.from(t)];

  CommissionMode mode;

  /// ASCII text as the user typed it (Bangla digits are normalized).
  String text;

  /// Bands, used when [mode] is [CommissionMode.tiered].
  final List<TierInput> tiers;

  /// Parsed flat value in hundredths of the unit, or null if invalid.
  int? get value => RateCodec.parse(DigitFormatter.toLatin(text));

  /// Seeds two bands from the current flat rate when switching to tiers.
  void ensureTiers() {
    if (tiers.length >= 2) return;
    tiers
      ..clear()
      ..add(
        TierInput(
          upTo: '1000',
          mode: mode == CommissionMode.tiered
              ? CommissionMode.perThousand
              : mode,
          value: text,
        ),
      )
      ..add(
        TierInput(
          mode: mode == CommissionMode.tiered
              ? CommissionMode.perThousand
              : mode,
          value: text,
        ),
      );
  }

  /// The bands as domain objects, or null when any field is unusable.
  List<CommissionTier>? get tiersParsed {
    final out = <CommissionTier>[];
    for (var i = 0; i < tiers.length; i++) {
      final t = tiers[i];
      final v = t.valueParsed;
      if (v == null || !RateCodec.isPlausible(t.mode, v)) return null;
      final last = i == tiers.length - 1;
      Money? bound;
      if (!last) {
        bound = t.upToParsed;
        if (bound == null) return null;
      }
      out.add(CommissionTier(upTo: bound, mode: t.mode, value: v));
    }
    return out;
  }

  /// Null when valid, otherwise a short problem code.
  String? get problem {
    if (mode == CommissionMode.tiered) {
      final parsed = tiersParsed;
      if (parsed == null) return 'invalid';
      return validateTiers(parsed) == null ? null : 'tiers';
    }
    final v = value;
    if (v == null) return 'invalid';
    if (!RateCodec.isPlausible(mode, v)) return 'high';
    return null;
  }
}

String rateModeLabel(AppLocalizations l10n, CommissionMode m) => switch (m) {
  CommissionMode.perThousand => l10n.rateModePerThousand,
  CommissionMode.percent => l10n.rateModePercent,
  CommissionMode.fixed => l10n.rateModeFixed,
  CommissionMode.tiered => l10n.rateModeTiered,
};

class RateRow extends StatefulWidget {
  const RateRow({
    super.key,
    required this.title,
    required this.input,
    required this.onChanged,
  });

  final String title;
  final RateInput input;
  final VoidCallback onChanged;

  @override
  State<RateRow> createState() => _RateRowState();
}

class _RateRowState extends State<RateRow> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.input.text,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changed() {
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final input = widget.input;
    final tiered = input.mode == CommissionMode.tiered;
    final problem = input.problem;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<CommissionMode>(
                  initialValue: input.mode,
                  isExpanded: true,
                  items: [
                    for (final m in CommissionMode.values)
                      DropdownMenuItem(
                        value: m,
                        child: Text(rateModeLabel(l10n, m)),
                      ),
                  ],
                  onChanged: (m) {
                    if (m == null) return;
                    input.mode = m;
                    if (m == CommissionMode.tiered) input.ensureTiers();
                    _changed();
                  },
                ),
              ),
              if (!tiered) ...[
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.rateValue,
                      errorText: switch (problem) {
                        'invalid' => l10n.rateInvalid,
                        'high' => l10n.rateTooHigh,
                        _ => null,
                      },
                    ),
                    onChanged: (t) {
                      input.text = t;
                      _changed();
                    },
                  ),
                ),
              ],
            ],
          ),
          if (tiered) ...[
            const SizedBox(height: 8),
            for (var i = 0; i < input.tiers.length; i++)
              _TierRow(
                key: ObjectKey(input.tiers[i]),
                tier: input.tiers[i],
                isLast: i == input.tiers.length - 1,
                canRemove: input.tiers.length > 2,
                onChanged: _changed,
                onRemove: () {
                  input.tiers.removeAt(i);
                  _changed();
                },
              ),
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l10n.tierAdd),
                  onPressed: () {
                    final at = input.tiers.length - 1;
                    input.tiers.insert(
                      at,
                      TierInput(
                        mode: input.tiers.last.mode,
                        value: input.tiers.last.value,
                      ),
                    );
                    _changed();
                  },
                ),
              ],
            ),
            if (problem != null)
              Text(
                problem == 'tiers' ? l10n.tierOrderProblem : l10n.rateInvalid,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ],
      ),
    );
  }
}

class _TierRow extends StatefulWidget {
  const _TierRow({
    super.key,
    required this.tier,
    required this.isLast,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final TierInput tier;
  final bool isLast;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  State<_TierRow> createState() => _TierRowState();
}

class _TierRowState extends State<_TierRow> {
  late final TextEditingController _upTo = TextEditingController(
    text: widget.tier.upTo,
  );
  late final TextEditingController _value = TextEditingController(
    text: widget.tier.value,
  );

  @override
  void dispose() {
    _upTo.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = widget.tier;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: widget.isLast
                ? Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Text(l10n.tierAbove),
                  )
                : TextField(
                    controller: _upTo,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.tierUpTo,
                      prefixText: '৳ ',
                    ),
                    onChanged: (v) {
                      t.upTo = v;
                      widget.onChanged();
                    },
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<CommissionMode>(
              initialValue: t.mode,
              isExpanded: true,
              items: [
                for (final m in CommissionMode.values)
                  if (m != CommissionMode.tiered)
                    DropdownMenuItem(
                      value: m,
                      child: Text(
                        rateModeLabel(l10n, m),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
              ],
              onChanged: (m) {
                if (m == null) return;
                t.mode = m;
                widget.onChanged();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _value,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.rateValue),
              onChanged: (v) {
                t.value = v;
                widget.onChanged();
              },
            ),
          ),
          IconButton(
            tooltip: '×',
            icon: const Icon(Icons.close),
            onPressed: widget.canRemove ? widget.onRemove : null,
          ),
        ],
      ),
    );
  }
}
