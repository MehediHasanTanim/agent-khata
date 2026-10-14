import 'dart:io';

import 'package:drift/drift.dart' hide Column;
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
import '../../core/widgets/khata_widgets.dart';
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
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          Widget kv(String k, String v) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  k,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    v,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    kv(
                      l10n.diagEncryption,
                      info.isEncrypted
                          ? l10n.diagEncrypted(info.cipherVersion!)
                          : l10n.diagNotEncrypted,
                    ),
                    kv(l10n.diagJournal, info.journalMode.toUpperCase()),
                    kv(l10n.diagSchema, digits.localize('${info.userVersion}')),
                    if (_dbBytes != null)
                      kv(
                        l10n.diagDbSize,
                        '${digits.localize((_dbBytes! / 1024).toStringAsFixed(0))} KB',
                      ),
                    kv(l10n.diagEntries, digits.localize('$_txnCount')),
                    kv('Ads', ref.read(adsServiceProvider).status),
                    kv(
                      l10n.diagColdStart,
                      firstFrameMs == null
                          ? '-'
                          : l10n.diagMs(digits.localize('$firstFrameMs')),
                    ),
                    kv(
                      l10n.diagWriteBench,
                      _benchMs == null
                          ? '-'
                          : l10n.diagBenchResult(digits.localize('$_benchMs')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  backgroundColor: scheme.tertiaryContainer,
                  foregroundColor: scheme.onSurface,
                ),
                onPressed: _running ? null : _runBench,
                child: Text(l10n.diagRunBench),
              ),
              const SizedBox(height: 10),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
                onPressed: _checking ? null : _check,
                child: Text(l10n.diagRunCheck),
              ),
              if (_report != null) ...[
                const SizedBox(height: 10),
                NoticeBanner(
                  margin: EdgeInsets.zero,
                  icon: _report!.isHealthy
                      ? LucideIcons.badgeCheck
                      : LucideIcons.circleAlert,
                  tone: _report!.isHealthy
                      ? BannerTone.info
                      : BannerTone.warning,
                  text: _report!.isHealthy
                      ? l10n.diagVerified
                      : l10n.diagProblem,
                ),
              ],
              const SizedBox(height: 10),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  backgroundColor: scheme.tertiaryContainer,
                  foregroundColor: scheme.onSurface,
                ),
                icon: const Icon(LucideIcons.share),
                label: Text(l10n.diagShareReport),
                onPressed: () => _shareReport(info),
              ),
            ],
          );
        },
      ),
    );
  }
}
