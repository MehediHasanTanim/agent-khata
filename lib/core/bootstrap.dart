import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';
import '../features/backup/backup_service.dart';
import 'db/database_key_store.dart';
import 'db/database_opener.dart';
import 'providers.dart';
import 'security/secure_key_value_store.dart';
import 'telemetry/analytics.dart';
import 'telemetry/crash_log.dart';

enum Flavor { dev, prod }

/// Time from process start (approx.) to first frame, for the S0-04 check.
final Stopwatch appStartWatch = Stopwatch();

/// Set after the first frame is rendered.
int? firstFrameMs;

Future<void> bootstrap(Flavor flavor) async {
  appStartWatch.start();
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('bn');
  await initializeDateFormatting('en');
  final supportDir = await getApplicationSupportDirectory();
  final crashLog = CrashLog(File('${supportDir.path}/crash.log'))..install();
  final prefs = await SharedPreferences.getInstance();
  final liveName = flavor == Flavor.dev ? 'khata_dev.db' : 'khata.db';
  // A restore staged by the previous run replaces the database here, before
  // anything opens it.
  await BackupService.applyPending(supportDir, liveName);
  final keyHex = await DatabaseKeyStore(const SecureKeyValueStore())
      .getOrCreateKeyHex();
  final db = openEncryptedDatabase(keyHex, fileName: liveName);
  // Force the connection open now so a key or cipher problem fails fast.
  await db.info();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        flavorProvider.overrideWithValue(flavor),
        crashLogProvider.overrideWithValue(crashLog),
        analyticsProvider.overrideWithValue(
          LocalFileAnalytics(
            File('${supportDir.path}/analytics.log'),
            enabled: () => prefs.getBool('pref_analytics_opt_in') ?? false,
          ),
        ),
      ],
      child: KhataApp(flavor: flavor),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => firstFrameMs = appStartWatch.elapsedMilliseconds,
  );
}
