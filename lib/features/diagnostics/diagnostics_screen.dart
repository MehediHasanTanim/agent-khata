import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/ads/ad_widgets.dart';
import '../../core/bootstrap.dart';
import '../../core/db/app_database.dart';
import '../../core/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import '../backup/restore_flow.dart' show liveDbFileName;
import '../transactions/integrity_checker.dart';

/// Device-side health: encryption status, timings, a "books verified" check
/// and a report the user can send to support. Also the place for the S0-04
/// feasibility numbers (cold start, write speed).
class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  late final Future<DbInfo> _info = ref.read(databaseProvider).info();
  int? _benchMs;
  bool _running = false;
  IntegrityReport? _report;
  bool _checking = false;
  int? _dbBytes;
  int _txnCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadFacts);
  }

  Future<void> _loadFacts() async {
    final db = ref.read(databaseProvider);
    final dir = await getApplicationSupportDirectory();
    final file = File(
      '${dir.path}/${liveDbFileName(ref.read(flavorProvider))}',
    );
    final count = await db
        .customSelect('SELECT COUNT(*) AS c FROM txn')
        .getSingle();
    if (!mounted) return;
    setState(() {
      _dbBytes = file.existsSync() ? file.lengthSync() : null;
      _txnCount = count.read<int>('c');
    });
  }

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

  Future<void> _check() async {
    setState(() => _checking = true);
    final r = await LedgerIntegrityChecker(ref.read(databaseProvider)).run();
    if (!mounted) return;
    setState(() {
      _report = r;
      _checking = false;
    });
  }

  Future<void> _shareReport(DbInfo info) async {
    final pkg = await PackageInfo.fromPlatform();
    final counts = await ref.read(analyticsCountsProvider.future);
    final crash = ref.read(crashLogProvider)?.read() ?? '';
    final report =
        _report ??
        await LedgerIntegrityChecker(ref.read(databaseProvider)).run();
    final tail = crash.length > 4000
        ? crash.substring(crash.length - 4000)
        : crash;
    final text = StringBuffer()
      ..writeln('Agent Khata diagnostics')
      ..writeln('version: ${pkg.version}+${pkg.buildNumber}')
      ..writeln('flavor: ${ref.read(flavorProvider).name}')
      ..writeln('schema: ${info.userVersion}')
      ..writeln('encrypted: ${info.isEncrypted} (${info.cipherVersion})')
      ..writeln('journal: ${info.journalMode}')
      ..writeln('db_bytes: $_dbBytes')
      ..writeln('transactions: $_txnCount')
      ..writeln('cold_start_ms: $firstFrameMs')
      ..writeln('books_healthy: ${report.isHealthy}')
      ..writeln('unbalanced: ${report.unbalancedTxnIds.length}')
      ..writeln('mismatches: ${report.balanceMismatches.length}')
      ..writeln('usage_counts: $counts')
      ..writeln('--- crash log tail ---')
      ..writeln(tail.isEmpty ? '(none)' : tail);
    await SharePlus.instance.share(
      ShareParams(text: text.toString(), subject: 'Agent Khata diagnostics'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final digits = ref.watch(preferencesProvider).digits;
    return Scaffold(
      bottomNavigationBar: const AdFooter(),
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
                  info.isEncrypted
                      ? LucideIcons.shieldCheck
                      : LucideIcons.triangleAlert,
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
              if (_dbBytes != null)
                ListTile(
                  title: Text(l10n.diagDbSize),
                  subtitle: Text(
                    '${digits.localize((_dbBytes! / 1024).toStringAsFixed(0))} KB',
                  ),
                ),
              ListTile(
                title: Text(l10n.diagEntries),
                subtitle: Text(digits.localize('$_txnCount')),
              ),
              ListTile(
                title: const Text('Ads'),
                subtitle: Text(ref.read(adsServiceProvider).status),
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
              const Divider(),
              ListTile(
                title: Text(l10n.diagIntegrity),
                subtitle: _report == null
                    ? null
                    : Text(
                        _report!.isHealthy
                            ? l10n.diagVerified
                            : l10n.diagProblem,
                      ),
                leading: Icon(
                  _report == null
                      ? LucideIcons.clipboardCheck
                      : _report!.isHealthy
                      ? LucideIcons.badgeCheck
                      : LucideIcons.circleAlert,
                  color: _report == null
                      ? null
                      : _report!.isHealthy
                      ? context.tokens.cashIn
                      : Theme.of(context).colorScheme.error,
                ),
                trailing: FilledButton(
                  onPressed: _checking ? null : _check,
                  child: Text(l10n.diagRunCheck),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  icon: const Icon(LucideIcons.share),
                  label: Text(l10n.diagShareReport),
                  onPressed: () => _shareReport(info),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
