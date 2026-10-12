import 'package:flutter/material.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/gen/app_localizations.dart';

class BalanceCardData {
  const BalanceCardData({
    required this.id,
    required this.label,
    required this.balance,
    required this.isLow,
  });

  final String id;
  final String label;
  final Money balance;
  final bool isLow;
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.data,
    required this.amountText,
    required this.hidden,
    this.onTap,
  });

  final BalanceCardData data;
  final String amountText;
  final bool hidden;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final warn = context.tokens.warning;
    final negative = data.balance.isNegative && !hidden;
    return Semantics(
      container: true,
      label: '${data.label} $amountText',
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: data.isLow || negative
              ? BorderSide(color: warn, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 148, minHeight: 88),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(data.label, style: theme.textTheme.bodyLarge),
                      if (data.isLow) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.warning_amber, size: 18, color: warn),
                        Text(
                          l10n.homeLow,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: warn,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    amountText,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: negative ? warn : null,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (hidden)
                    Text(
                      l10n.homeTapToReveal,
                      style: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
