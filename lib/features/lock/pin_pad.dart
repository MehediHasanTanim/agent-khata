import 'package:flutter/material.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../core/security/pin_service.dart';
import '../../l10n/gen/app_localizations.dart';

/// Dots showing how many PIN digits were entered.
class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.length});

  final int length;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < PinService.maxLength; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < length ? color : Colors.transparent,
                border: Border.all(color: color, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

/// Numeric keypad: 1-9, delete, 0, confirm. All keys are at least 64dp.
class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.digits,
    required this.onDigit,
    required this.onDelete,
    required this.onSubmit,
    this.enabled = true,
    this.canSubmit = true,
  });

  final DigitFormatter digits;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;
  final bool enabled;
  final bool canSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget digitKey(String d) => _Key(
      label: digits.localize(d),
      semanticLabel: digits.localize(d),
      onPressed: enabled ? () => onDigit(d) : null,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(children: [for (final d in row) digitKey(d)]),
        Row(
          children: [
            _Key(
              icon: Icons.backspace_outlined,
              semanticLabel: l10n.pinDelete,
              onPressed: enabled ? onDelete : null,
            ),
            digitKey('0'),
            _Key(
              icon: Icons.check_rounded,
              semanticLabel: 'OK',
              onPressed: enabled && canSubmit ? onSubmit : null,
              filled: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    this.label,
    this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.filled = false,
  });

  final String? label;
  final IconData? icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = label != null
        ? Text(label!, style: Theme.of(context).textTheme.headlineMedium)
        : Icon(icon, size: 28);
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(64, 64)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Semantics(
          label: semanticLabel,
          button: true,
          excludeSemantics: true,
          child: SizedBox(
            height: 72,
            child: filled
                ? FilledButton(onPressed: onPressed, style: style, child: child)
                : OutlinedButton(
                    onPressed: onPressed,
                    style: style,
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}
