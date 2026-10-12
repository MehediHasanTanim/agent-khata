import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Schema v1 is intentionally empty (S0-03). Tables arrive in S1-01.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// In-memory database for tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Facts about the open connection, used by the feasibility check (S0-04)
  /// and the diagnostics screen.
  Future<DbInfo> info() async {
    final cipher = await customSelect('PRAGMA cipher_version').get();
    final journal = await customSelect('PRAGMA journal_mode').getSingle();
    final version = await customSelect('PRAGMA user_version').getSingle();
    return DbInfo(
      cipherVersion: cipher.isEmpty
          ? null
          : cipher.first.data.values.first as String?,
      journalMode: journal.data.values.first as String,
      userVersion: version.data.values.first as int,
    );
  }
}

class DbInfo {
  const DbInfo({
    required this.cipherVersion,
    required this.journalMode,
    required this.userVersion,
  });

  /// `null` when the linked SQLite has no SQLCipher support.
  final String? cipherVersion;
  final String journalMode;
  final int userVersion;

  bool get isEncrypted => cipherVersion != null && cipherVersion!.isNotEmpty;
}

/// Opens the encrypted on-disk database with [keyHex] (64 hex chars).
///
/// Throws [StateError] if the linked SQLite is not SQLCipher, rather than
/// silently falling back to an unencrypted file.
AppDatabase openEncryptedDatabase(
  String keyHex, {
  String fileName = 'khata.db',
}) {
  if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(keyHex)) {
    throw ArgumentError.value(keyHex, 'keyHex', 'must be 64 hex characters');
  }
  return AppDatabase(
    LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, fileName));
      return NativeDatabase.createInBackground(
        file,
        setup: (raw) {
          final cipher = raw.select('PRAGMA cipher_version;');
          if (cipher.isEmpty) {
            throw StateError(
              'SQLCipher is not available; refusing to open an '
              'unencrypted database.',
            );
          }
          raw.execute('''PRAGMA key = "x'$keyHex'";''');
          // Fails with "file is not a database" on a wrong key.
          raw.select('SELECT count(*) FROM sqlite_master;');
          raw.execute('PRAGMA journal_mode = WAL;');
          raw.execute('PRAGMA synchronous = NORMAL;');
        },
      );
    }),
  );
}
