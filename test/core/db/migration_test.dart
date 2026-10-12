import 'dart:io';

import 'package:agentkhata/core/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

/// Upgrades a database file that was left at an older schema version, the
/// way a phone with an old install would, and checks data and guards survive.
void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('akmig');
    file = File('${dir.path}/khata.db');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  AppDatabase open() => AppDatabase(NativeDatabase(file));

  Future<Set<String>> tables(AppDatabase db) async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    return {for (final r in rows) r.read<String>('name')};
  }

  Future<int> triggerCount(AppDatabase db) async =>
      (await db
              .customSelect(
                "SELECT COUNT(*) AS c FROM sqlite_master WHERE type = 'trigger'",
              )
              .getSingle())
          .read<int>('c');

  test('v1 (empty Sprint 0 skeleton) upgrades to the current schema', () async {
    final legacy = raw.sqlite3.open(file.path)
      ..execute('PRAGMA user_version = 1');
    legacy.close();

    final db = open();
    addTearDown(db.close);
    final info = await db.info();
    expect(info.userVersion, db.schemaVersion);

    final names = await tables(db);
    for (final t in [
      'account',
      'txn',
      'ledger_entry',
      'commission_rule',
      'customer',
      'day_close',
      'day_close_line',
      'expense_category',
      'app_user',
      'audit_log',
      'setting',
      'balance_snapshot',
    ]) {
      expect(names, contains(t), reason: 'table $t');
    }
    expect(await triggerCount(db), greaterThanOrEqualTo(8));
  });

  test('v2 (before balance snapshots) keeps data and gains the new table', () async {
    // Build a current database, then roll it back to what v2 looked like.
    var db = open();
    await db.customStatement(
      'INSERT INTO account (id, kind, label, opening_paisa, created_at) '
      "VALUES ('a1', 'cash', 'Cash', 12345, 1)",
    );
    await db.customStatement(
      "INSERT INTO setting (key, value) VALUES ('shop_name', 'Rahim')",
    );
    await db.close();

    final legacy = raw.sqlite3.open(file.path)
      ..execute('DROP TABLE balance_snapshot')
      ..execute('PRAGMA user_version = 2');
    legacy.close();

    db = open();
    addTearDown(db.close);
    expect((await db.info()).userVersion, 3);
    expect(await tables(db), contains('balance_snapshot'));

    final acc = await db.select(db.accounts).getSingle();
    expect(acc.openingPaisa, 12345);
    final setting = await db.select(db.settings).getSingle();
    expect(setting.value, 'Rahim');

    // The guards are still in force after the upgrade.
    await db.customStatement(
      'INSERT INTO txn (id, type, occurred_at, recorded_at, amount_paisa, '
      "created_by, device_id) VALUES ('t', 'cash_out', 0, 0, 100, 'o', 'd')",
    );
    await expectLater(
      db.customStatement("DELETE FROM txn WHERE id = 't'"),
      throwsA(predicate((e) => e.toString().contains('cannot be deleted'))),
    );

    // And balance snapshots are usable.
    await db.customStatement(
      'INSERT INTO balance_snapshot (account_id, business_date, balance_paisa, '
      "max_txn_rowid, created_at) VALUES ('a1', '2026-10-20', 12345, 1, 1)",
    );
  });

  test('reopening a current database changes nothing', () async {
    var db = open();
    await db.customStatement(
      "INSERT INTO setting (key, value) VALUES ('k', 'v')",
    );
    final before = await tables(db);
    await db.close();

    db = open();
    addTearDown(db.close);
    expect(await tables(db), before);
    expect((await db.select(db.settings).getSingle()).value, 'v');
  });
}
