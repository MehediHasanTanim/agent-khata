import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import 'history_filter.dart';

class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.charge,
    required this.commission,
    required this.occurredAt,
    required this.isVoid,
    required this.isLocked,
    this.accountLabel,
    this.customerNumber,
    this.customerName,
    this.reference,
    this.note,
    this.voidReason,
    this.replacesTxnId,
  });

  final String id;
  final TransactionType type;
  final Money amount;
  final Money charge;
  final Money commission;
  final DateTime occurredAt;
  final bool isVoid;

  /// Belongs to a closed day.
  final bool isLocked;
  final String? accountLabel;
  final String? customerNumber;
  final String? customerName;
  final String? reference;
  final String? note;
  final String? voidReason;
  final String? replacesTxnId;

  HistoryCursor get cursor =>
      HistoryCursor(occurredAt.millisecondsSinceEpoch, id);
}

class HistoryTotals {
  const HistoryTotals({this.count = 0, this.amount = Money.zero});

  final int count;
  final Money amount;
}

/// Newest-first paged history with filters, plus totals for the same filter.
class HistoryQueries {
  HistoryQueries(this._db);

  final AppDatabase _db;

  Set<TableInfo<Table, dynamic>> get _tables => {
    _db.txns,
    _db.accounts,
    _db.ledgerEntries,
    _db.customers,
  };

  static const _selectSql = '''
SELECT t.id, t.type, t.amount_paisa, t.charge_paisa, t.commission_paisa,
       t.occurred_at, t.status, t.day_close_id, t.customer_number,
       t.reference, t.note, t.void_reason, t.replaces_txn_id,
       c.name AS customer_name,
       (SELECT a.label FROM ledger_entry le
          JOIN account a ON a.id = le.account_id
         WHERE le.txn_id = t.id AND a.kind IN ('wallet', 'load')
         ORDER BY le.line_no LIMIT 1) AS account_label
FROM txn t
LEFT JOIN customer c ON c.id = t.customer_id''';

  Future<List<HistoryItem>> page(
    HistoryFilter filter, {
    HistoryCursor? after,
    int limit = 50,
  }) async {
    final built = buildHistoryWhere(filter, cursor: after);
    final rows = await _db
        .customSelect(
          '''
$_selectSql
${built.where}
ORDER BY t.occurred_at DESC, t.id DESC
LIMIT ?''',
          variables: [...built.variables, Variable.withInt(limit)],
          readsFrom: _tables,
        )
        .get();
    return rows.map(_item).toList();
  }

  Future<HistoryItem?> byId(String id) async {
    final rows = await _db
        .customSelect(
          '$_selectSql WHERE t.id = ?',
          variables: [Variable.withString(id)],
          readsFrom: _tables,
        )
        .get();
    return rows.isEmpty ? null : _item(rows.first);
  }

  Future<HistoryTotals> totals(HistoryFilter filter) async {
    final built = buildHistoryWhere(filter.copyWith(includeVoid: false));
    final row = await _db
        .customSelect(
          '''
SELECT COUNT(*) AS c, COALESCE(SUM(t.amount_paisa), 0) AS s
FROM txn t
LEFT JOIN customer c ON c.id = t.customer_id
${built.where}''',
          variables: built.variables,
          readsFrom: _tables,
        )
        .getSingle();
    return HistoryTotals(
      count: row.read<int>('c'),
      amount: Money.paisa(row.read<int>('s')),
    );
  }

  static HistoryItem _item(QueryRow r) => HistoryItem(
    id: r.read<String>('id'),
    type: TransactionType.fromDb(r.read<String>('type')),
    amount: Money.paisa(r.read<int>('amount_paisa')),
    charge: Money.paisa(r.read<int>('charge_paisa')),
    commission: Money.paisa(r.read<int>('commission_paisa')),
    occurredAt: DateTime.fromMillisecondsSinceEpoch(
      r.read<int>('occurred_at'),
      isUtc: true,
    ),
    isVoid: r.read<String>('status') == 'void',
    isLocked: r.readNullable<String>('day_close_id') != null,
    accountLabel: r.readNullable<String>('account_label'),
    customerNumber: r.readNullable<String>('customer_number'),
    customerName: r.readNullable<String>('customer_name'),
    reference: r.readNullable<String>('reference'),
    note: r.readNullable<String>('note'),
    voidReason: r.readNullable<String>('void_reason'),
    replacesTxnId: r.readNullable<String>('replaces_txn_id'),
  );
}

/// A row of an account statement.
class LedgerLine {
  const LedgerLine({
    required this.txnId,
    required this.type,
    required this.occurredAt,
    required this.delta,
    required this.balance,
    required this.isVoid,
    this.note,
    this.customerNumber,
  });

  final String txnId;
  final TransactionType type;
  final DateTime occurredAt;

  /// Signed effect on this account (+ in, - out).
  final Money delta;

  /// Running balance after this line (unchanged by voided lines).
  final Money balance;
  final bool isVoid;
  final String? note;
  final String? customerNumber;
}

class AccountLedgerQueries {
  AccountLedgerQueries(this._db);

  final AppDatabase _db;

  /// Statement lines for [accountId], newest first. The running balance is
  /// computed over the account's whole history, so a date filter still shows
  /// true balances.
  Future<List<LedgerLine>> page(
    String accountId, {
    DateTime? from,
    DateTime? to,
    int limit = 100,
    int offset = 0,
  }) async {
    final rows = await _db
        .customSelect(
          '''
SELECT * FROM (
  SELECT t.id AS txn_id, t.type, t.status, t.occurred_at, t.recorded_at,
         t.note, t.customer_number, le.id AS le_id, le.delta_paisa,
         a.opening_paisa + SUM(
           CASE WHEN t.status = 'active' THEN le.delta_paisa ELSE 0 END
         ) OVER (
           ORDER BY t.occurred_at, t.recorded_at, le.id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
         ) AS balance
  FROM ledger_entry le
  JOIN txn t ON t.id = le.txn_id
  JOIN account a ON a.id = le.account_id
  WHERE le.account_id = ?
)
WHERE (? IS NULL OR occurred_at >= ?) AND (? IS NULL OR occurred_at < ?)
ORDER BY occurred_at DESC, recorded_at DESC, le_id DESC
LIMIT ? OFFSET ?''',
          variables: [
            Variable.withString(accountId),
            Variable<int>(from?.toUtc().millisecondsSinceEpoch),
            Variable<int>(from?.toUtc().millisecondsSinceEpoch),
            Variable<int>(to?.toUtc().millisecondsSinceEpoch),
            Variable<int>(to?.toUtc().millisecondsSinceEpoch),
            Variable.withInt(limit),
            Variable.withInt(offset),
          ],
          readsFrom: {_db.txns, _db.ledgerEntries, _db.accounts},
        )
        .get();
    return [
      for (final r in rows)
        LedgerLine(
          txnId: r.read<String>('txn_id'),
          type: TransactionType.fromDb(r.read<String>('type')),
          occurredAt: DateTime.fromMillisecondsSinceEpoch(
            r.read<int>('occurred_at'),
            isUtc: true,
          ),
          delta: Money.paisa(r.read<int>('delta_paisa')),
          balance: Money.paisa(r.read<int>('balance')),
          isVoid: r.read<String>('status') == 'void',
          note: r.readNullable<String>('note'),
          customerNumber: r.readNullable<String>('customer_number'),
        ),
    ];
  }
}

/// Accounts a transaction touched, split into the leg money left and the leg
/// it arrived in (external account excluded).
class TxnLegs {
  const TxnLegs({this.fromAccountId, this.toAccountId, this.fromPaisa = 0});

  final String? fromAccountId;
  final String? toAccountId;

  /// What actually left the `from` account (differs from the amount for a
  /// float purchase with a charge or discount).
  final int fromPaisa;
}

/// Everything shown on the transaction detail screen.
class TransactionDetail {
  const TransactionDetail({
    required this.item,
    required this.legs,
    required this.entries,
    required this.audit,
    required this.createdBy,
    required this.recordedAt,
    this.ruleSummary,
    this.replacedByTxnId,
  });

  final HistoryItem item;
  final TxnLegs legs;
  final List<DetailEntry> entries;
  final List<AuditLogRow> audit;
  final String createdBy;
  final DateTime recordedAt;

  /// e.g. `per_thousand 400` for the rule used, if one was.
  final String? ruleSummary;
  final String? replacedByTxnId;
}

class DetailEntry {
  const DetailEntry(this.accountLabel, this.kind, this.delta);

  final String accountLabel;
  final AccountKind kind;
  final Money delta;
}

class TransactionDetailLoader {
  TransactionDetailLoader(this._db, this._history);

  final AppDatabase _db;
  final HistoryQueries _history;

  Future<TransactionDetail?> load(String txnId) async {
    final txn = await (_db.select(
      _db.txns,
    )..where((t) => t.id.equals(txnId))).getSingleOrNull();
    if (txn == null) return null;

    final item = await _history.byId(txnId);
    if (item == null) return null;

    final rows = await _db
        .customSelect(
          '''
SELECT le.account_id, le.delta_paisa, a.label, a.kind
FROM ledger_entry le JOIN account a ON a.id = le.account_id
WHERE le.txn_id = ? ORDER BY le.line_no''',
          variables: [Variable.withString(txnId)],
          readsFrom: {_db.ledgerEntries, _db.accounts},
        )
        .get();
    final entries = <DetailEntry>[];
    String? from;
    String? to;
    var fromDelta = 0;
    var toDelta = 0;
    for (final r in rows) {
      final kind = AccountKind.fromDb(r.read<String>('kind'));
      final delta = r.read<int>('delta_paisa');
      entries.add(
        DetailEntry(r.read<String>('label'), kind, Money.paisa(delta)),
      );
      if (kind == AccountKind.external) continue;
      final id = r.read<String>('account_id');
      if (delta < fromDelta) {
        fromDelta = delta;
        from = id;
      }
      if (delta > toDelta) {
        toDelta = delta;
        to = id;
      }
    }

    String? summary;
    if (txn.commissionRuleId != null) {
      final rule = await (_db.select(
        _db.commissionRules,
      )..where((t) => t.id.equals(txn.commissionRuleId!))).getSingleOrNull();
      if (rule != null) summary = '${rule.mode} ${rule.value}';
    }

    final replacedBy = await (_db.select(
      _db.txns,
    )..where((t) => t.replacesTxnId.equals(txnId))).getSingleOrNull();

    final audit =
        await (_db.select(_db.auditLogs)
              ..where((t) => t.entity.equals('txn') & t.entityId.equals(txnId))
              ..orderBy([(t) => OrderingTerm.asc(t.at)]))
            .get();

    return TransactionDetail(
      item: item,
      legs: TxnLegs(
        fromAccountId: from,
        toAccountId: to,
        fromPaisa: -fromDelta,
      ),
      entries: entries,
      audit: audit,
      createdBy: txn.createdBy,
      recordedAt: DateTime.fromMillisecondsSinceEpoch(
        txn.recordedAt,
        isUtc: true,
      ),
      ruleSummary: summary,
      replacedByTxnId: replacedBy?.id,
    );
  }
}
