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

  /// Rewinds a current-schema file to what [version] looked like.
  void rollBackTo(int version) {
    final db = raw.sqlite3.open(file.path);
    if (version < 6) db.execute('DROP TABLE recurring_expense');
    if (version < 5) {
      db
        ..execute('DROP TABLE shift_line')
        ..execute('DROP TABLE shift')
        ..execute('ALTER TABLE app_user DROP COLUMN can_close_day')
        ..execute('ALTER TABLE app_user DROP COLUMN created_at');
    }
    if (version < 4) {
      db
        ..execute('DROP TABLE due_settlement')
        ..execute('DROP TABLE due');
    }
    if (version < 3) db.execute('DROP TABLE balance_snapshot');
    db
      ..execute('PRAGMA user_version = $version')
      ..close();
  }

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
      'due',
      'due_settlement',
      'shift',
      'shift_line',
      'recurring_expense',
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

    rollBackTo(2);

    db = open();
    addTearDown(db.close);
    expect((await db.info()).userVersion, db.schemaVersion);
    expect(await tables(db), containsAll(['balance_snapshot', 'due']));

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

  test(
    'v3 (before customer dues) gains the due tables and their guards',
    () async {
      var db = open();
      await db.customStatement(
        'INSERT INTO account (id, kind, label, created_at) '
        "VALUES ('a1', 'cash', 'Cash', 1)",
      );
      await db.close();

      rollBackTo(3);

      db = open();
      addTearDown(db.close);
      expect((await db.info()).userVersion, db.schemaVersion);
      expect(await tables(db), containsAll(['due', 'due_settlement']));
      expect((await db.select(db.accounts).get()), hasLength(1));

      final triggers = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'trigger' AND name LIKE 'trg_due%'",
          )
          .get();
      expect(triggers, hasLength(4));
    },
  );

  test(
    'v4 (before staff and shifts) keeps users and gains the new parts',
    () async {
      var db = open();
      await db.customStatement(
        "INSERT INTO app_user (id, name, role) VALUES ('owner', 'Owner', 'owner')",
      );
      await db.close();
      rollBackTo(4);

      db = open();
      addTearDown(db.close);
      expect((await db.info()).userVersion, db.schemaVersion);
      expect(await tables(db), containsAll(['shift', 'shift_line']));

      final user = await db.select(db.appUsers).getSingle();
      expect(user.name, 'Owner');
      expect(user.canCloseDay, isFalse);

      await expectLater(
        db.customStatement("DELETE FROM shift WHERE id = 'x'"),
        completes,
      ); // nothing to delete, but the trigger exists:
      await db.customStatement(
        "INSERT INTO shift (id, user_id, started_at) VALUES ('s', 'owner', 1)",
      );
      await expectLater(
        db.customStatement("DELETE FROM shift WHERE id = 's'"),
        throwsA(predicate((e) => e.toString().contains('cannot be deleted'))),
      );
    },
  );

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
