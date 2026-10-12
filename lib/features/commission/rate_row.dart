import 'package:flutter/material.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../l10n/gen/app_localizations.dart';
import 'commission_rule.dart';
import 'rate_codec.dart';

/// Editable (mode, value) pair used by onboarding and the rates screen.
class RateInput {
  RateInput({required this.mode, required int value})
    : text = RateCodec.format(value);

  CommissionMode mode;

  /// ASCII text as the user typed it (Bangla digits are normalized).
  String text;

  /// Parsed value in hundredths of the unit, or null if the text is invalid.
  int? get value => RateCodec.parse(DigitFormatter.toLatin(text));

  /// Null when valid, otherwise a short problem code.
  String? get problem {
    final v = value;
    if (v == null) return 'invalid';
    if (!RateCodec.isPlausible(mode, v)) return 'high';
    return null;
  }
}

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

  String _modeLabel(AppLocalizations l10n, CommissionMode m) => switch (m) {
    CommissionMode.perThousand => l10n.rateModePerThousand,
    CommissionMode.percent => l10n.rateModePercent,
    CommissionMode.fixed => l10n.rateModeFixed,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final problem = widget.input.problem;
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
                  initialValue: widget.input.mode,
                  isExpanded: true,
                  items: [
                    for (final m in CommissionMode.values)
                      DropdownMenuItem(
                        value: m,
                        child: Text(_modeLabel(l10n, m)),
                      ),
                  ],
                  onChanged: (m) {
                    if (m == null) return;
                    setState(() => widget.input.mode = m);
                    widget.onChanged();
                  },
                ),
              ),
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
                    setState(() => widget.input.text = t);
                    widget.onChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
