import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/bootstrap.dart';
import '../../core/db/app_database.dart';
import '../../core/db/database_key_store.dart';
import '../../core/db/database_opener.dart';
import '../../core/i18n/date_labels.dart';
import '../../core/providers.dart';
import '../../core/security/secure_key_value_store.dart';
import '../../l10n/gen/app_localizations.dart';
import 'backup_codec.dart';
import 'backup_service.dart';

const stagedDbFileName = 'khata.restore.db';

String liveDbFileName(Flavor flavor) =>
    flavor == Flavor.dev ? 'khata_dev.db' : 'khata.db';

String backupErrorText(AppLocalizations l10n, BackupException e) =>
    switch (e.code) {
      'wrong_passphrase' => l10n.bkWrongPassphrase,
      'newer_schema' => l10n.bkNewerSchema,
      'bad_file' || 'unsupported_format' => l10n.bkBadFile,
      'weak_passphrase' => l10n.bkTooShort,
      _ => l10n.bkCorrupt,
    };

/// Builds a [BackupService] for the live database.
Future<BackupService> buildBackupService(WidgetRef ref) async {
  final info = await PackageInfo.fromPlatform();
  return BackupService(
    db: ref.read(databaseProvider),
    appVersion: '${info.version}+${info.buildNumber}',
    deviceId: ref.read(deviceIdProvider),
  );
}

/// Asks for a passphrase (twice when [confirm]); null if cancelled.
Future<String?> askPassphrase(BuildContext context, {required bool confirm}) {
  final l10n = AppLocalizations.of(context);
  final a = TextEditingController();
  final b = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) {
        final tooShort = a.text.length < BackupCodec.minPassphraseLength;
        final mismatch = confirm && a.text != b.text;
        return AlertDialog(
          title: Text(l10n.bkPassphrase),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (confirm) Text(l10n.bkPassphraseWarn),
                TextField(
                  key: const ValueKey('pass-1'),
                  controller: a,
                  obscureText: true,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.bkPassphrase,
                    errorText: confirm && a.text.isNotEmpty && tooShort
                        ? l10n.bkTooShort
                        : null,
                  ),
                  onChanged: (_) => setLocal(() {}),
                ),
                if (confirm)
                  TextField(
                    key: const ValueKey('pass-2'),
                    controller: b,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.bkPassphraseConfirm,
                      errorText: b.text.isNotEmpty && mismatch
                          ? l10n.bkMismatch
                          : null,
                    ),
                    onChanged: (_) => setLocal(() {}),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: a.text.isEmpty || (confirm && (tooShort || mismatch))
                  ? null
                  : () => Navigator.pop(ctx, a.text),
              child: Text(l10n.next),
            ),
          ],
        );
      },
    ),
  ).whenComplete(() {
    a.dispose();
    b.dispose();
  });
}

/// Pick a `.cbk`, confirm, decrypt, restore into a staging database and
/// schedule the swap for the next start. Returns whether a restore was
/// staged. Shows its own dialogs and errors.
Future<bool> runRestoreFlow(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  void say(String t) => messenger.showSnackBar(SnackBar(content: Text(t)));

  final picked = await FilePicker.pickFile(dialogTitle: l10n.bkRestore);
  if (picked == null || !context.mounted) return false;
  final Uint8List bytes;
  try {
    bytes = await picked.readAsBytes();
  } on Object {
    say(l10n.bkBadFile);
    return false;
  }

  final service = await buildBackupService(ref);
  final BackupInfo info;
  try {
    info = service.inspect(bytes);
  } on BackupException catch (e) {
    say(backupErrorText(l10n, e));
    return false;
  }
  if (!context.mounted) return false;

  final prefs = ref.read(preferencesProvider);
  final labels = DateLabels(
    languageCode: prefs.languageCode,
    digits: prefs.digits,
  );
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.bkRestoreConfirmTitle),
      content: Text(
        '${l10n.bkRestoreInfo(labels.dateTime(info.createdAt))}\n\n'
        '${l10n.bkRestoreConfirmBody}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.next),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return false;

  final pass = await askPassphrase(context, confirm: false);
  if (pass == null || !context.mounted) return false;

  // Progress while Argon2id runs and the staging database is filled.
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(l10n.bkRestoreWorking)),
          ],
        ),
      ),
    ),
  );

  AppDatabase? staged;
  try {
    final dir = await getApplicationSupportDirectory();
    for (final suffix in ['', '-wal', '-shm']) {
      final f = File('${dir.path}/$stagedDbFileName$suffix');
      if (await f.exists()) await f.delete();
    }
    final keyHex = await DatabaseKeyStore(const SecureKeyValueStore())
        .getOrCreateKeyHex();
    staged = openEncryptedDatabase(keyHex, fileName: stagedDbFileName);
    await service.restoreInto(staged, bytes, pass);
    await staged.close();
    staged = null;
    await BackupService.markPending(dir, stagedDbFileName);
    await ref.read(onboardingDoneProvider.notifier).complete();
  } on BackupException catch (e) {
    await staged?.close();
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      say(backupErrorText(l10n, e));
    }
    return false;
  } on Object {
    await staged?.close();
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      say(l10n.bkCorrupt);
    }
    return false;
  }

  if (!context.mounted) return true;
  Navigator.of(context, rootNavigator: true).pop();
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      content: Text(l10n.bkRestoreDone),
      actions: [
        FilledButton(
          onPressed: () => SystemNavigator.pop(),
          child: Text(l10n.bkCloseApp),
        ),
      ],
    ),
  );
  return true;
}
