import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';
import '../transactions/integrity_checker.dart';
import 'backup_codec.dart';

/// What a backup file says about itself (readable without the passphrase).
class BackupInfo {
  const BackupInfo({
    required this.createdAt,
    required this.schemaVersion,
    required this.appVersion,
    required this.deviceId,
  });

  final DateTime createdAt;
  final int schemaVersion;
  final String appVersion;
  final String deviceId;
}

/// Tables in dependency order (parents first) for restore.
const backupTableOrder = <String>[
  'account',
  'recurring_expense',
  'customer',
  'app_user',
  'expense_category',
  'commission_rule',
  'setting',
  'day_close',
  'txn',
  'ledger_entry',
  'due',
  'due_settlement',
  'shift',
  'shift_line',
  'day_close_line',
  'audit_log',
  'balance_snapshot',
];

/// Logical (table by table) backup and restore.
///
/// A logical dump is independent of the device's database key, so a backup
/// can be restored on a new phone, and of the SQLite build in use.
class BackupService {
  BackupService({
    required this._db,
    required this.appVersion,
    required this.deviceId,
    this._codec = const BackupCodec(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final BackupCodec _codec;
  final String appVersion;
  final String deviceId;
  final DateTime Function() _clock;

  static const _pendingMarker = 'restore.pending';

  /// Every row of every backed-up table as JSON-friendly maps.
  Future<Map<String, List<Map<String, Object?>>>> dumpTables() async {
    final out = <String, List<Map<String, Object?>>>{};
    for (final table in backupTableOrder) {
      final rows = await _db.customSelect('SELECT * FROM $table').get();
      out[table] = [for (final r in rows) Map<String, Object?>.from(r.data)];
    }
    return out;
  }

  /// Encrypted `.cbk` bytes of the whole database.
  Future<Uint8List> createBackup(
    String passphrase, {
    KdfParams kdf = KdfParams.standard,
  }) async {
    final payload = {
      'format': 1,
      'schema_version': _db.schemaVersion,
      'tables': await dumpTables(),
    };
    return _codec.encode(
      payloadJson: utf8.encode(jsonEncode(payload)),
      passphrase: passphrase,
      schemaVersion: _db.schemaVersion,
      appVersion: appVersion,
      deviceId: deviceId,
      createdAt: _clock(),
      kdf: kdf,
    );
  }

  /// Header details; throws [BackupException] for non-backup files.
  BackupInfo inspect(Uint8List file) {
    final h = _codec.readHeader(file);
    return BackupInfo(
      createdAt: h.createdAt,
      schemaVersion: h.schemaVersion,
      appVersion: h.appVersion,
      deviceId: h.deviceId,
    );
  }

  /// Decrypts [file] and loads it into [target], a fresh database. Verifies
  /// the result with the ledger integrity checker before returning.
  ///
  /// Backups from an older schema restore fine (missing tables and columns
  /// take their defaults); backups from a newer schema are rejected.
  Future<void> restoreInto(
    AppDatabase target,
    Uint8List file,
    String passphrase,
  ) async {
    final header = _codec.readHeader(file);
    if (header.schemaVersion > target.schemaVersion) {
      throw BackupException(
        'newer_schema',
        '${header.schemaVersion} > ${target.schemaVersion}',
      );
    }
    final bytes = await _codec.decode(file, passphrase);
    final Object? parsed;
    try {
      parsed = jsonDecode(utf8.decode(bytes));
    } on Object {
      throw const BackupException('corrupt', 'json');
    }
    if (parsed is! Map || parsed['tables'] is! Map) {
      throw const BackupException('corrupt', 'payload');
    }
    final tables = Map<String, Object?>.from(parsed['tables'] as Map);

    await target.transaction(() async {
      for (final name in backupTableOrder) {
        final raw = tables[name];
        if (raw == null) continue;
        final columns = await _columnsOf(target, name);
        for (final row in raw as List<Object?>) {
          final map = Map<String, Object?>.from(row! as Map);
          final names = [
            for (final k in map.keys)
              if (columns.contains(k)) k,
          ];
          if (names.isEmpty) continue;
          await target.customInsert(
            'INSERT INTO $name (${names.join(', ')}) '
            'VALUES (${List.filled(names.length, '?').join(', ')})',
            variables: [for (final n in names) _variable(map[n])],
          );
        }
      }
    });

    final report = await LedgerIntegrityChecker(target).run();
    if (!report.isHealthy) {
      throw const BackupException('corrupt', 'integrity check failed');
    }
  }

  static Variable<Object> _variable(Object? v) => switch (v) {
    null => const Variable<Object>(null),
    final int i => Variable<int>(i),
    final String s => Variable<String>(s),
    final double d => Variable<double>(d),
    final bool b => Variable<bool>(b),
    _ => throw BackupException('corrupt', 'value type ${v.runtimeType}'),
  };

  static Future<Set<String>> _columnsOf(AppDatabase db, String table) async {
    final rows = await db.customSelect('PRAGMA table_info($table)').get();
    return {for (final r in rows) r.read<String>('name')};
  }

  // --- staged restore (applied by the next app start) ---------------------

  /// Records that [stagedFileName] (a fully restored database in [dir]) must
  /// replace the live database on the next start.
  static Future<void> markPending(Directory dir, String stagedFileName) async {
    await File('${dir.path}/$_pendingMarker')
        .writeAsString(jsonEncode({'staged': stagedFileName}));
  }

  /// If a restore is pending, keeps the current database as
  /// `<liveName>.pre-restore` and swaps the restored one in. Must run before
  /// the database is opened. Returns whether a swap happened.
  static Future<bool> applyPending(Directory dir, String liveName) async {
    final marker = File('${dir.path}/$_pendingMarker');
    if (!await marker.exists()) return false;
    try {
      final data = jsonDecode(await marker.readAsString()) as Map;
      final staged = File('${dir.path}/${data['staged']}');
      if (!await staged.exists()) return false;

      final live = File('${dir.path}/$liveName');
      final keep = File('${dir.path}/$liveName.pre-restore');
      for (final suffix in ['', '-wal', '-shm']) {
        final f = File('${dir.path}/$liveName$suffix');
        final k = File('${keep.path}$suffix');
        if (await k.exists()) await k.delete();
        if (await f.exists()) await f.rename(k.path);
      }
      for (final suffix in ['', '-wal', '-shm']) {
        final f = File('${staged.path}$suffix');
        if (await f.exists()) await f.rename('${live.path}$suffix');
      }
      return true;
    } finally {
      if (await marker.exists()) await marker.delete();
    }
  }
}
