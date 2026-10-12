// ignore_for_file: recursive_getters (Drift's documented `check()` pattern)
import 'package:drift/drift.dart';

// Schema per docs/design/agent-cashbook-technical-design.md section 5.
// IDs are device-generated UUIDv7 strings; times are UTC epoch millis;
// money is integer paisa.

@DataClassName('AccountRow')
class Accounts extends Table {
  @override
  String get tableName => 'account';

  TextColumn get id => text()();
  // cash | wallet | load | bank | expense | external
  TextColumn get kind => text()();
  TextColumn get provider => text().nullable()();
  TextColumn get label => text()();
  TextColumn get number => text().nullable()();
  IntColumn get openingPaisa => integer().withDefault(const Constant(0))();
  IntColumn get lowAlertPaisa => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TxnRow')
@TableIndex(name: 'idx_txn_occurred', columns: {#occurredAt})
@TableIndex(name: 'idx_txn_type_day', columns: {#type, #occurredAt})
@TableIndex(name: 'idx_txn_status', columns: {#status})
@TableIndex(name: 'idx_txn_customer', columns: {#customerNumber})
@TableIndex(name: 'idx_txn_reference', columns: {#reference})
class Txns extends Table {
  @override
  String get tableName => 'txn';

  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get occurredAt => integer()();
  IntColumn get recordedAt => integer()();
  IntColumn get amountPaisa =>
      integer().check(amountPaisa.isBiggerThanValue(0))();
  IntColumn get chargePaisa => integer().withDefault(const Constant(0))();
  IntColumn get commissionPaisa => integer().withDefault(const Constant(0))();
  TextColumn get commissionRuleId => text().nullable()();
  BoolColumn get commissionOverridden =>
      boolean().withDefault(const Constant(false))();
  TextColumn get customerId => text().nullable()();
  TextColumn get customerNumber => text().nullable()();
  TextColumn get reference => text().nullable()();
  TextColumn get note => text().nullable()();
  // active | void
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get voidReason => text().nullable()();
  IntColumn get voidedAt => integer().nullable()();
  TextColumn get replacesTxnId => text().nullable()();
  TextColumn get dayCloseId => text().nullable()();
  TextColumn get createdBy => text()();
  TextColumn get shiftId => text().nullable()();
  TextColumn get deviceId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LedgerEntryRow')
@TableIndex(name: 'idx_le_account', columns: {#accountId})
@TableIndex(name: 'idx_le_txn', columns: {#txnId})
class LedgerEntries extends Table {
  @override
  String get tableName => 'ledger_entry';

  TextColumn get id => text()();
  TextColumn get txnId => text().references(Txns, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  IntColumn get deltaPaisa => integer()();
  IntColumn get lineNo => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CommissionRuleRow')
class CommissionRules extends Table {
  @override
  String get tableName => 'commission_rule';

  TextColumn get id => text()();
  TextColumn get provider => text()();
  TextColumn get txnType => text()();
  // per_thousand | percent | fixed
  TextColumn get mode => text()();
  IntColumn get value => integer()();
  TextColumn get tiersJson => text().nullable()();
  IntColumn get effectiveFrom => integer()();
  IntColumn get effectiveTo => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CustomerRow')
class Customers extends Table {
  @override
  String get tableName => 'customer';

  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DayCloseRow')
class DayCloses extends Table {
  @override
  String get tableName => 'day_close';

  TextColumn get id => text()();
  // 'YYYY-MM-DD' in Asia/Dhaka
  TextColumn get businessDate => text().unique()();
  // closed | reopened
  TextColumn get status => text()();
  TextColumn get note => text().nullable()();
  TextColumn get closedBy => text().nullable()();
  IntColumn get closedAt => integer().nullable()();
  TextColumn get reopenedBy => text().nullable()();
  IntColumn get reopenedAt => integer().nullable()();
  TextColumn get reopenReason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DayCloseLineRow')
class DayCloseLines extends Table {
  @override
  String get tableName => 'day_close_line';

  TextColumn get dayCloseId => text().references(DayCloses, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  IntColumn get expectedPaisa => integer()();
  IntColumn get actualPaisa => integer()();
  IntColumn get variancePaisa => integer()();
  TextColumn get adjustmentTxnId => text().nullable()();

  @override
  Set<Column> get primaryKey => {dayCloseId, accountId};
}

@DataClassName('ExpenseCategoryRow')
class ExpenseCategories extends Table {
  @override
  String get tableName => 'expense_category';

  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppUserRow')
class AppUsers extends Table {
  @override
  String get tableName => 'app_user';

  TextColumn get id => text()();
  TextColumn get name => text()();
  // owner | staff
  TextColumn get role => text()();
  TextColumn get pinHash => text().nullable()();
  BoolColumn get canSeeProfit => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AuditLogRow')
@TableIndex(name: 'idx_audit_entity', columns: {#entity, #entityId})
class AuditLogs extends Table {
  @override
  String get tableName => 'audit_log';

  TextColumn get id => text()();
  IntColumn get at => integer()();
  TextColumn get userId => text()();
  // txn_create | txn_void | day_close | day_reopen | rate_change | ...
  TextColumn get action => text()();
  TextColumn get entity => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get beforeJson => text().nullable()();
  TextColumn get afterJson => text().nullable()();
  TextColumn get reason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SettingRow')
class Settings extends Table {
  @override
  String get tableName => 'setting';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Balance of an account as of a day close (S4-09). Live balance =
/// the latest valid snapshot plus entries of transactions inserted after it.
@DataClassName('BalanceSnapshotRow')
class BalanceSnapshots extends Table {
  @override
  String get tableName => 'balance_snapshot';

  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get businessDate => text()();
  IntColumn get balancePaisa => integer()();

  /// Highest `txn.rowid` that was included when the snapshot was taken.
  IntColumn get maxTxnRowid => integer()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {accountId, businessDate};
}
