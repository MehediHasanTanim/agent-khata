import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';

/// A row for "recent transactions" lists.
class RecentTxn {
  const RecentTxn({
    required this.id,
    required this.type,
    required this.amount,
    required this.commission,
    required this.occurredAt,
    this.accountLabel,
    this.customerNumber,
  });

  final String id;
  final TransactionType type;
  final Money amount;
  final Money commission;
  final DateTime occurredAt;

  /// Wallet or load account involved, if any.
  final String? accountLabel;
  final String? customerNumber;
}

/// Totals for one business day.
class DaySummary {
  const DaySummary({
    this.count = 0,
    this.cashInVolume = Money.zero,
    this.cashOutVolume = Money.zero,
    this.commission = Money.zero,
  });

  final int count;
  final Money cashInVolume;
  final Money cashOutVolume;
  final Money commission;
}

/// Read-side queries for home and the entry screens.
class TransactionQueries {
  TransactionQueries(this._db);

  final AppDatabase _db;

  Set<ResultSetImplementation<dynamic, dynamic>> get _reads => {
    _db.txns,
    _db.ledgerEntries,
    _db.accounts,
  };

  Stream<List<RecentTxn>> watchRecent({int limit = 5}) => _db
      .customSelect(
        '''
SELECT t.id, t.type, t.amount_paisa, t.commission_paisa, t.occurred_at,
       t.customer_number,
       (SELECT a.label FROM ledger_entry le
          JOIN account a ON a.id = le.account_id
         WHERE le.txn_id = t.id AND a.kind IN ('wallet', 'load')
         ORDER BY le.line_no LIMIT 1) AS account_label
FROM txn t
WHERE t.status = 'active'
ORDER BY t.occurred_at DESC, t.recorded_at DESC
LIMIT ?''',
        variables: [Variable.withInt(limit)],
        readsFrom: _reads,
      )
      .watch()
      .map((rows) => rows.map(_recent).toList());

  static RecentTxn _recent(QueryRow r) => RecentTxn(
    id: r.read<String>('id'),
    type: TransactionType.fromDb(r.read<String>('type')),
    amount: Money.paisa(r.read<int>('amount_paisa')),
    commission: Money.paisa(r.read<int>('commission_paisa')),
    occurredAt: DateTime.fromMillisecondsSinceEpoch(
      r.read<int>('occurred_at'),
      isUtc: true,
    ),
    accountLabel: r.readNullable<String>('account_label'),
    customerNumber: r.readNullable<String>('customer_number'),
  );

  Stream<DaySummary> watchSummary(DateTime startUtc, DateTime endUtc) => _db
      .customSelect(
        '''
SELECT type, COUNT(*) AS c, SUM(amount_paisa) AS vol,
       SUM(commission_paisa) AS comm
FROM txn
WHERE status = 'active' AND occurred_at >= ? AND occurred_at < ?
GROUP BY type''',
        variables: [
          Variable.withInt(startUtc.millisecondsSinceEpoch),
          Variable.withInt(endUtc.millisecondsSinceEpoch),
        ],
        readsFrom: {_db.txns},
      )
      .watch()
      .map(_summary);

  static DaySummary _summary(List<QueryRow> rows) {
    var count = 0;
    var cashIn = 0;
    var cashOut = 0;
    var commission = 0;
    for (final r in rows) {
      final type = TransactionType.fromDb(r.read<String>('type'));
      count += r.read<int>('c');
      commission += r.read<int>('comm');
      if (type == TransactionType.cashIn) cashIn += r.read<int>('vol');
      if (type == TransactionType.cashOut) cashOut += r.read<int>('vol');
    }
    return DaySummary(
      count: count,
      cashInVolume: Money.paisa(cashIn),
      cashOutVolume: Money.paisa(cashOut),
      commission: Money.paisa(commission),
    );
  }

  /// The user's most frequently used amounts for [type], most frequent
  /// first (ties: most recent first).
  Future<List<Money>> frequentAmounts(
    TransactionType type, {
    int limit = 4,
  }) async {
    final rows = await _db
        .customSelect(
          '''
SELECT amount_paisa, COUNT(*) AS c, MAX(occurred_at) AS last
FROM txn
WHERE type = ? AND status = 'active'
GROUP BY amount_paisa
ORDER BY c DESC, last DESC
LIMIT ?''',
          variables: [
            Variable.withString(type.dbName),
            Variable.withInt(limit),
          ],
          readsFrom: {_db.txns},
        )
        .get();
    return [for (final r in rows) Money.paisa(r.read<int>('amount_paisa'))];
  }

  Future<Money?> lastAmount(TransactionType type) async {
    final row =
        await (_db.select(_db.txns)
              ..where(
                (t) => t.type.equals(type.dbName) & t.status.equals('active'),
              )
              ..orderBy([
                (t) => OrderingTerm.desc(t.occurredAt),
                (t) => OrderingTerm.desc(t.recordedAt),
              ])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : Money.paisa(row.amountPaisa);
  }

  /// True when an active transaction with the same type, amount, account and
  /// customer number was recorded within [within] before [now].
  Future<bool> hasDuplicate({
    required TransactionType type,
    required Money amount,
    required String accountId,
    required DateTime now,
    String? customerNumber,
    Duration within = const Duration(minutes: 2),
  }) async {
    final since = now.toUtc().subtract(within).millisecondsSinceEpoch;
    final rows = await _db
        .customSelect(
          '''
SELECT 1 FROM txn t
WHERE t.type = ? AND t.amount_paisa = ? AND t.status = 'active'
  AND t.recorded_at >= ?
  AND t.customer_number IS ?
  AND EXISTS (SELECT 1 FROM ledger_entry le
              WHERE le.txn_id = t.id AND le.account_id = ?)
LIMIT 1''',
          variables: [
            Variable.withString(type.dbName),
            Variable.withInt(amount.paisa),
            Variable.withInt(since),
            Variable<String>(customerNumber),
            Variable.withString(accountId),
          ],
          readsFrom: _reads,
        )
        .get();
    return rows.isNotEmpty;
  }
}
