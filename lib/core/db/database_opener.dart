import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

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
