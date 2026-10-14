import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/ads/ad_widgets.dart';
import '../../core/i18n/date_labels.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import 'backup_codec.dart';
import 'restore_flow.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  Future<void> _backup() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final pass = await askPassphrase(context, confirm: true);
    if (pass == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final service = await buildBackupService(ref);
      final bytes = await service.createBackup(pass);
      final now = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      final name =
          'khata-${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}.cbk';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$name')..writeAsBytesSync(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: l10n.bkShareText),
      );
      await ref
          .read(preferencesProvider.notifier)
          .update(
            (p) => p.copyWith(
              lastBackupAtMs: DateTime.now().toUtc().millisecondsSinceEpoch,
            ),
          );
      await ref.read(analyticsProvider).log('backup_created', {'ok': true});
      messenger.showSnackBar(SnackBar(content: Text(l10n.bkDone)));
    } on BackupException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(backupErrorText(l10n, e))));
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.bkFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final labels = DateLabels(
      languageCode: prefs.languageCode,
      digits: prefs.digits,
    );
    final last = prefs.lastBackupAtMs;
    return Scaffold(
      bottomNavigationBar: const AdFooter(),
      appBar: AppBar(title: Text(l10n.bkTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  last == null
                      ? l10n.bkNever
                      : l10n.bkLast(
                          labels.dateTime(
                            DateTime.fromMillisecondsSinceEpoch(
                              last,
                              isUtc: true,
                            ),
                          ),
                        ),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.bkWhyBody,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const ValueKey('backup-now'),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 64)),
            icon: const Icon(LucideIcons.cloudUpload),
            label: Text(_busy ? l10n.bkCreating : l10n.bkNow),
            onPressed: _busy ? null : _backup,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 60),
              backgroundColor: theme.colorScheme.tertiaryContainer,
              foregroundColor: theme.colorScheme.onSurface,
            ),
            icon: const Icon(LucideIcons.rotateCcw),
            label: Text(l10n.bkRestore),
            onPressed: _busy ? null : () => runRestoreFlow(context, ref),
          ),
        ],
      ),
    );
  }
}
