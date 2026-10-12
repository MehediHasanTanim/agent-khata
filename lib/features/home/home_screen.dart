import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import '../settings/settings_screen.dart';

/// Placeholder home screen; balance cards and quick entry arrive in Sprint 2.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.homePlaceholder,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.sampleAmount,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.south_west, color: tokens.cashIn),
              const SizedBox(width: 8),
              Text(
                money.format(const Money.paisa(123456700)),
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(color: tokens.cashIn),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.north_east, color: tokens.cashOut),
              const SizedBox(width: 8),
              Text(
                money.format(const Money.paisa(-250050)),
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(color: tokens.cashOut),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
