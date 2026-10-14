import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/ledger/transaction_type.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import '../commission/commission_rates_screen.dart' show transactionTypeLabel;

/// Direction of a transaction from the agent's cash drawer point of view.
enum FlowDirection { moneyIn, moneyOut, neutral }

FlowDirection directionOf(TransactionType t) => switch (t) {
  TransactionType.cashIn ||
  TransactionType.sendMoney ||
  TransactionType.billPay ||
  TransactionType.flexiload ||
  TransactionType.dueSettled ||
  TransactionType.dueTaken ||
  TransactionType.commissionReceived => FlowDirection.moneyIn,
  TransactionType.cashOut || TransactionType.expense => FlowDirection.moneyOut,
  _ => FlowDirection.neutral,
};

IconData iconFor(TransactionType t) => switch (directionOf(t)) {
  FlowDirection.moneyIn => LucideIcons.arrowDownLeft,
  FlowDirection.moneyOut => LucideIcons.arrowUpRight,
  FlowDirection.neutral => LucideIcons.arrowLeftRight,
};

Color colorFor(BuildContext context, TransactionType t) =>
    switch (directionOf(t)) {
      FlowDirection.moneyIn => context.tokens.cashIn,
      FlowDirection.moneyOut => context.tokens.cashOut,
      FlowDirection.neutral => Theme.of(context).colorScheme.primary,
    };

/// Icon + text label for a transaction type (never colour alone).
class TypeLabel extends StatelessWidget {
  const TypeLabel(this.type, {super.key});

  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconFor(type), size: 18, color: colorFor(context, type)),
        const SizedBox(width: 6),
        Text(transactionTypeLabel(l10n, type)),
      ],
    );
  }
}
