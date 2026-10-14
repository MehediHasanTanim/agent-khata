import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ads/ad_widgets.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/khata_widgets.dart';
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
  DueDirection _tab = DueDirection.theyOwe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final totals = ref.watch(_dueTotalsProvider).value ?? const DueTotals();
    final dues = ref.watch(_openDuesProvider(_query)).value ?? const [];

    final visible = [
      for (final d in dues)
        if (d.direction == _tab) d,
    ];
    final shownTotal = _tab == DueDirection.theyOwe
        ? totals.theyOwe
        : totals.iOwe;

    return Scaffold(
      bottomNavigationBar: const AdFooter(),
      appBar: AppBar(title: Text(l10n.duesTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: PillSegmented<DueDirection>(
              value: _tab,
              onChanged: (v) => setState(() => _tab = v),
              options: [
                (DueDirection.theyOwe, l10n.duesTheyOwe),
                (DueDirection.iOwe, l10n.duesIOwe),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.duesSearch,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          HeroCard(
            label: _tab == DueDirection.theyOwe
                ? l10n.duesTotalTheyOwe
                : l10n.duesTotalIOwe,
            value: money.format(shownTotal),
          ),
          const SizedBox(height: 8),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(42),
                        topRight: Radius.circular(42),
                        bottomRight: Radius.circular(42),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                    child: Icon(
                      Icons.menu_book_outlined,
                      size: 38,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.duesEmpty,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: 'Caprasimo',
                    ),
                  ),
                ],
              ),
            ),
          for (final d in visible)
            KhataTile(
              key: ValueKey('due-${d.id}'),
              leading: InitialAvatar(d.displayName),
              title: Text(d.displayName),
              subtitle: Text(
                [
                  if (d.customerPhone != null && d.customerName != null)
                    d.customerPhone!,
                  if (d.note != null) d.note!,
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                money.format(d.remaining),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _tab == DueDirection.theyOwe
                      ? tokens.cashIn
                      : tokens.cashOut,
                ),
              ),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => DueDetailScreen(dueId: d.id)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: FilledButton.icon(
              key: const ValueKey('add-due'),
              icon: const Icon(Icons.add),
              label: Text(l10n.duesAdd),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const DueFormScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
