import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';
import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/money/money.dart';
import '../../core/utils/uuid_v7.dart';

class AccountRepository {
  AccountRepository(this._db, this._ids, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final IdGenerator _ids;
  final DateTime Function() _clock;

  static Account fromRow(AccountRow r) => Account(
    id: r.id,
    kind: AccountKind.fromDb(r.kind),
    label: r.label,
    provider: r.provider,
    number: r.number,
    opening: Money.paisa(r.openingPaisa),
    lowAlert: r.lowAlertPaisa == null ? null : Money.paisa(r.lowAlertPaisa!),
    isActive: r.isActive,
    sortOrder: r.sortOrder,
  );

  /// Creates the hidden external counter-account if missing. Idempotent.
  Future<void> ensureSystemAccounts() async {
    await _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            id: kExternalAccountId,
            kind: AccountKind.external.dbName,
            label: 'External',
            createdAt: _clock().toUtc().millisecondsSinceEpoch,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<String> create({
    required AccountKind kind,
    required String label,
    String? provider,
    String? number,
    Money opening = Money.zero,
    Money? lowAlert,
    int sortOrder = 0,
  }) async {
    if (kind == AccountKind.external) {
      throw ArgumentError.value(kind, 'kind', 'system account');
    }
    final id = _ids.next();
    await _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            id: id,
            kind: kind.dbName,
            label: label,
            provider: Value(provider),
            number: Value(number),
            openingPaisa: Value(opening.paisa),
            lowAlertPaisa: Value(lowAlert?.paisa),
            sortOrder: Value(sortOrder),
            createdAt: _clock().toUtc().millisecondsSinceEpoch,
          ),
        );
    return id;
  }

  Future<void> update(
    String id, {
    String? label,
    String? number,
    Money? lowAlert,
    int? sortOrder,
  }) async {
    await (_db.update(_db.accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(
        label: label == null ? const Value.absent() : Value(label),
        number: number == null ? const Value.absent() : Value(number),
        lowAlertPaisa: lowAlert == null
            ? const Value.absent()
            : Value(lowAlert.paisa),
        sortOrder: sortOrder == null ? const Value.absent() : Value(sortOrder),
      ),
    );
  }

  /// Sets or clears (null) the low-balance threshold.
  Future<void> setLowAlert(String id, Money? threshold) async {
    await (_db.update(_db.accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(lowAlertPaisa: Value(threshold?.paisa)),
    );
  }

  /// Deactivated accounts keep their history but cannot receive postings.
  Future<void> setActive(String id, {required bool active}) async {
    await (_db.update(_db.accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(isActive: Value(active)),
    );
  }

  Future<Account?> byId(String id) async {
    final row = await (_db.select(
      _db.accounts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : fromRow(row);
  }

  /// Agent-visible accounts (no system accounts, no expense categories).
  Stream<List<Account>> watchCounted({bool includeInactive = false}) {
    final query = _db.select(_db.accounts)
      ..where(
        (t) =>
            t.kind.isIn(countedKinds.map((k) => k.dbName).toList()) &
            (includeInactive ? const Constant(true) : t.isActive.equals(true)),
      )
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    return query.watch().map((rows) => rows.map(fromRow).toList());
  }

  /// Active accounts of one [kind], e.g. expense categories.
  Stream<List<Account>> watchByKind(AccountKind kind) {
    final query = _db.select(_db.accounts)
      ..where((t) => t.kind.equals(kind.dbName) & t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(fromRow).toList());
  }

  /// Balance = latest still-valid snapshot (written at day close) plus the
  /// entries of transactions inserted after it. A snapshot is ignored when
  /// any transaction older than it was voided since, so the result always
  /// equals a from-scratch recompute (which the integrity checker verifies).
  static const _balanceSql = '''
WITH ranked AS (
  SELECT s.*, ROW_NUMBER() OVER (
           PARTITION BY s.account_id
           ORDER BY s.created_at DESC, s.max_txn_rowid DESC,
                    s.business_date DESC) AS rn
  FROM balance_snapshot s
),
snap AS (
  SELECT r.account_id, r.balance_paisa, r.max_txn_rowid, r.created_at
  FROM ranked r
  WHERE r.rn = 1
    AND NOT EXISTS (
      SELECT 1 FROM txn t
      WHERE t.voided_at >= r.created_at AND t.rowid <= r.max_txn_rowid)
)
SELECT a.id AS account_id,
       COALESCE(snap.balance_paisa, a.opening_paisa) + COALESCE((
         SELECT SUM(le.delta_paisa)
         FROM ledger_entry le
         JOIN txn t ON t.id = le.txn_id
         WHERE le.account_id = a.id AND t.status = 'active'
           AND (snap.account_id IS NULL OR t.rowid > snap.max_txn_rowid)
       ), 0) AS balance
FROM account a
LEFT JOIN snap ON snap.account_id = a.id''';

  /// Live balances of every account, re-emitted on any ledger change.
  Stream<Map<String, Money>> watchBalances() => _db
      .customSelect(
        _balanceSql,
        readsFrom: {
          _db.accounts,
          _db.ledgerEntries,
          _db.txns,
          _db.balanceSnapshots,
        },
      )
      .watch()
      .map(_toMap);

  Future<Map<String, Money>> balances() async => _toMap(
    await _db
        .customSelect(
          _balanceSql,
          readsFrom: {
            _db.accounts,
            _db.ledgerEntries,
            _db.txns,
            _db.balanceSnapshots,
          },
        )
        .get(),
  );

  Future<Money> balanceOf(String accountId) async =>
      (await balances())[accountId] ?? Money.zero;

  static Map<String, Money> _toMap(List<QueryRow> rows) => {
    for (final r in rows)
      r.read<String>('account_id'): Money.paisa(r.read<int>('balance')),
  };
}
