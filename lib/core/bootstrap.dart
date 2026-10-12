import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';
import 'db/app_database.dart';
import 'db/database_key_store.dart';
import 'providers.dart';
import 'security/key_value_store.dart';

enum Flavor { dev, prod }

/// Time from process start (approx.) to first frame, for the S0-04 check.
final Stopwatch appStartWatch = Stopwatch();

/// Set after the first frame is rendered.
int? firstFrameMs;

Future<void> bootstrap(Flavor flavor) async {
  appStartWatch.start();
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final keyHex = await DatabaseKeyStore(const SecureKeyValueStore())
      .getOrCreateKeyHex();
  final db = openEncryptedDatabase(
    keyHex,
    fileName: flavor == Flavor.dev ? 'khata_dev.db' : 'khata.db',
  );
  // Force the connection open now so a key or cipher problem fails fast.
  await db.info();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: KhataApp(flavor: flavor),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => firstFrameMs = appStartWatch.elapsedMilliseconds,
  );
}
