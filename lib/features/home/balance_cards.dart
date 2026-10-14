import 'package:flutter/material.dart';

import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/gen/app_localizations.dart';

class BalanceCardData {
  const BalanceCardData({
    required this.id,
    required this.label,
    required this.balance,
    required this.isLow,
    this.account,
  });

  final String id;

  /// The account behind the card; null for the combined flexiload card.
  final Account? account;
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
    final scheme = theme.colorScheme;
    final isCash = data.account?.kind == AccountKind.cash;
    final isFlex = data.account == null;
    final bg = isCash
        ? scheme.secondary
        : (isFlex ? scheme.secondaryContainer : scheme.primaryContainer);
    final fg = isCash ? scheme.onSecondary : scheme.onSurface;
    final flagged = data.isLow || negative;
    return Semantics(
      container: true,
      label: '${data.label} $amountText',
      child: Material(
        color: bg,
        elevation: 0,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: flagged ? BorderSide(color: warn, width: 2.5) : BorderSide.none,
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 148, minHeight: 88),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: fg.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    amountText,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: negative ? warn : fg,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (data.isLow || hidden) ...[
                    const SizedBox(height: 6),
                    Text(
                      data.isLow ? '▼ ${l10n.homeLow}' : l10n.homeTapToReveal,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: data.isLow ? warn : fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
