import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import 'due_detail_screen.dart';
import 'due_form_screen.dart';
import 'dues_service.dart';

final _openDuesProvider = StreamProvider.autoDispose
    .family<List<DueView>, String>(
      (ref, query) => ref.watch(duesServiceProvider).watchOpen(query: query),
    );

final _dueTotalsProvider = StreamProvider.autoDispose<DueTotals>(
  (ref) => ref.watch(duesServiceProvider).watchTotals(),
);

/// Open baki, grouped by direction, with totals and search.
class DuesScreen extends ConsumerStatefulWidget {
  const DuesScreen({super.key});

  @override
  ConsumerState<DuesScreen> createState() => _DuesScreenState();
}

class _DuesScreenState extends ConsumerState<DuesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final totals = ref.watch(_dueTotalsProvider).value ?? const DueTotals();
    final dues = ref.watch(_openDuesProvider(_query)).value ?? const [];

    Widget totalCard(String label, String value, Color color) => Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.duesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add-due'),
        icon: const Icon(Icons.add),
        label: Text(l10n.duesAdd),
        onPressed: () => Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (_) => const DueFormScreen())),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                totalCard(
                  l10n.duesTotalTheyOwe,
                  money.format(totals.theyOwe),
                  tokens.cashIn,
                ),
                totalCard(
                  l10n.duesTotalIOwe,
                  money.format(totals.iOwe),
                  tokens.cashOut,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.duesSearch,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (dues.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(l10n.duesEmpty)),
            ),
          for (final d in dues)
            ListTile(
              key: ValueKey('due-${d.id}'),
              leading: Icon(
                d.direction == DueDirection.theyOwe
                    ? Icons.south_west
                    : Icons.north_east,
                color: d.direction == DueDirection.theyOwe
                    ? tokens.cashIn
                    : tokens.cashOut,
              ),
              title: Text(d.displayName),
              subtitle: Text(
                [
                  d.direction == DueDirection.theyOwe
                      ? l10n.duesTheyOwe
                      : l10n.duesIOwe,
                  if (d.customerPhone != null && d.customerName != null)
                    d.customerPhone!,
                  if (d.note != null) d.note!,
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                money.format(d.remaining),
                style: theme.textTheme.titleMedium,
              ),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => DueDetailScreen(dueId: d.id)),
              ),
            ),
        ],
      ),
    );
  }
}
