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
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => ActionChip(
                key: ValueKey('chip-${chips[i].paisa}'),
                label: Text(
                  money.format(chips[i]),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onPressed: () => onChip(chips[i]),
              ),
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
          child: OutlinedButton(
            key: ValueKey('key-$keyName'),
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: label != null
                ? Text(
                    label!,
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                : Icon(icon, size: 28),
          ),
        ),
      ),
    );
  }
}
