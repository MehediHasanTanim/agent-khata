import 'package:flutter/material.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';

/// In-app numeric keypad (not the system keyboard) with a "000" key and
/// quick-amount chips. All keys are 64dp tall for greasy hands and one-handed
/// use.
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    super.key,
    required this.digits,
    required this.chips,
    required this.onKey,
    required this.onBackspace,
    required this.onChip,
  });

  final DigitFormatter digits;
  final List<Money> chips;
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  final ValueChanged<Money> onChip;

  @override
  Widget build(BuildContext context) {
    final money = MoneyFormatter(digits: digits, showSymbol: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (chips.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Row(
              children: [
                for (var i = 0; i < chips.length && i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Material(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      shape: const StadiumBorder(),
                      child: InkWell(
                        key: ValueKey('chip-${chips[i].paisa}'),
                        customBorder: const StadiumBorder(),
                        onTap: () => onChip(chips[i]),
                        child: SizedBox(
                          height: 48,
                          child: Center(
                            child: Text(
                              money.format(chips[i]),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            children: [
              for (final k in row)
                _KeypadKey(
                  keyName: k,
                  label: digits.localize(k),
                  onPressed: () => onKey(k),
                ),
            ],
          ),
        Row(
          children: [
            _KeypadKey(
              keyName: '000',
              label: digits.localize('000'),
              onPressed: () => onKey('000'),
            ),
            _KeypadKey(
              keyName: '0',
              label: digits.localize('0'),
              onPressed: () => onKey('0'),
            ),
            _KeypadKey(
              keyName: 'backspace',
              icon: Icons.backspace_outlined,
              onPressed: onBackspace,
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    required this.keyName,
    this.label,
    this.icon,
    required this.onPressed,
  });

  final String keyName;
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: 64,
          child: FilledButton(
            key: ValueKey('key-$keyName'),
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: label != null
                ? Text(
                    label!,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  )
                : Icon(icon, size: 28),
          ),
        ),
      ),
    );
  }
}
