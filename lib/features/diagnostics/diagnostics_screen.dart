import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bootstrap.dart';
import '../../core/db/app_database.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';

/// Feasibility measurements for the SQLCipher decision gate (S0-04): cipher
/// status, journal mode, cold-start time and a write-speed test.
class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  late final Future<DbInfo> _info = ref.read(databaseProvider).info();
  int? _benchMs;
  bool _running = false;

  Future<void> _runBench() async {
    setState(() => _running = true);
    final db = ref.read(databaseProvider);
    final watch = Stopwatch()..start();
    await db.customStatement(
      'CREATE TEMP TABLE IF NOT EXISTS bench (id INTEGER PRIMARY KEY, v TEXT)',
    );
    await db.transaction(() async {
      for (var i = 0; i < 1000; i++) {
        await db.customInsert(
          'INSERT INTO bench (v) VALUES (?)',
          variables: [Variable<String>('row $i')],
        );
      }
    });
    await db.customStatement('DROP TABLE bench');
    watch.stop();
    if (!mounted) return;
    setState(() {
      _benchMs = watch.elapsedMilliseconds;
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final digits = ref.watch(preferencesProvider).digits;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.diagnostics)),
      body: FutureBuilder<DbInfo>(
        future: _info,
        builder: (context, snapshot) {
          final info = snapshot.data;
          if (info == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              ListTile(
                title: Text(l10n.diagEncryption),
                subtitle: Text(
                  info.isEncrypted
                      ? l10n.diagEncrypted(info.cipherVersion!)
                      : l10n.diagNotEncrypted,
                ),
                leading: Icon(
                  info.isEncrypted ? Icons.verified_user : Icons.warning_amber,
                ),
              ),
              ListTile(
                title: Text(l10n.diagJournal),
                subtitle: Text(info.journalMode.toUpperCase()),
              ),
              ListTile(
                title: Text(l10n.diagSchema),
                subtitle: Text(digits.localize('${info.userVersion}')),
              ),
              ListTile(
                title: Text(l10n.diagColdStart),
                subtitle: Text(
                  firstFrameMs == null
                      ? '-'
                      : l10n.diagMs(digits.localize('$firstFrameMs')),
                ),
              ),
              ListTile(
                title: Text(l10n.diagWriteBench),
                subtitle: Text(
                  _benchMs == null
                      ? '-'
                      : l10n.diagBenchResult(digits.localize('$_benchMs')),
                ),
                trailing: FilledButton(
                  onPressed: _running ? null : _runBench,
                  child: Text(l10n.diagRunBench),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
