import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'integrity_triggers.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Schema history:
/// - v1: empty skeleton (Sprint 0).
/// - v2: ledger schema and integrity triggers (Sprint 1).
/// - v3: balance snapshots written at day close (Sprint 4).
/// - v4: customer dues and settlements (Phase 2).
/// - v5: staff permissions columns and shifts (Phase 2).
/// - v6: recurring expenses (Phase 2).
@DriftDatabase(
  tables: [
    Accounts,
    Txns,
    LedgerEntries,
    CommissionRules,
    Customers,
    DayCloses,
    DayCloseLines,
    ExpenseCategories,
    AppUsers,
    AuditLogs,
    Settings,
    BalanceSnapshots,
    Dues,
    DueSettlements,
    Shifts,
    ShiftLines,
    RecurringExpenses,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// In-memory database for tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIntegrityTriggers();
      await _createDueTriggers();
      await _createShiftTriggers();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createAll();
        await _createIntegrityTriggers();
        await _createDueTriggers();
        await _createShiftTriggers();
      } else {
        if (from < 3) await m.createTable(balanceSnapshots);
        if (from < 4) {
          await m.createTable(dues);
          await m.createTable(dueSettlements);
          await _createDueTriggers();
        }
        if (from < 5) {
          await m.addColumn(appUsers, appUsers.canCloseDay);
          await m.addColumn(appUsers, appUsers.createdAt);
          await m.createTable(shifts);
          await m.createTable(shiftLines);
          await _createShiftTriggers();
        }
        if (from < 6) await m.createTable(recurringExpenses);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createIntegrityTriggers() async {
    for (final statement in integrityTriggerStatements) {
      await customStatement(statement);
    }
  }

  Future<void> _createShiftTriggers() async {
    for (final statement in shiftTriggerStatements) {
      await customStatement(statement);
    }
  }

  Future<void> _createDueTriggers() async {
    for (final statement in dueTriggerStatements) {
      await customStatement(statement);
    }
  }

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
