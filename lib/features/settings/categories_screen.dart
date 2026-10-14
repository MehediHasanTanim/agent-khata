import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ads/ad_widgets.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../entry/entry_providers.dart';

/// Add, rename and remove expense categories. Removing hides a category from
/// the entry screen; past expenses keep their label.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  Future<String?> _askName(BuildContext context, {String initial = ''}) async {
    final l10n = AppLocalizations.of(context);
    final c = TextEditingController(text: initial);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.entryNewCategory),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.entryCategoryName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    c.dispose();
    return (name == null || name.isEmpty) ? null : name;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cats = ref.watch(expenseAccountsProvider).value ?? const [];
    final repo = ref.read(accountRepositoryProvider);
    return Scaffold(
      bottomNavigationBar: const AdFooter(),
      appBar: AppBar(title: Text(l10n.categoriesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.categoryAdd),
        onPressed: () async {
          final name = await _askName(context);
          if (name != null) {
            await repo.create(kind: AccountKind.expense, label: name);
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          for (final c in cats)
            ListTile(
              title: Text(c.label),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l10n.categoryRename,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () async {
                      final name = await _askName(context, initial: c.label);
                      if (name != null) await repo.update(c.id, label: name);
                    },
                  ),
                  IconButton(
                    tooltip: l10n.categoryRemove,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => repo.setActive(c.id, active: false),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
