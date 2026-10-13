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

/// A number the agent serves repeatedly, with how they were last served.
class RegularCustomer {
  const RegularCustomer({
    required this.number,
    required this.type,
    required this.lastAmount,
    required this.uses,
    required this.lastAt,
    this.accountId,
    this.name,
  });

  final String number;
  final TransactionType type;
  final Money lastAmount;

  /// Wallet or operator account used last time.
  final String? accountId;
  final int uses;
  final DateTime lastAt;
  final String? name;

  String get displayName => (name != null && name!.isNotEmpty) ? name! : number;
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

  Stream<List<RecentTxn>> watchRecent({int limit = 5, String? createdBy}) => _db
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
  AND (? IS NULL OR t.created_by = ?)
ORDER BY t.occurred_at DESC, t.recorded_at DESC
LIMIT ?''',
        variables: [
          Variable<String>(createdBy),
          Variable<String>(createdBy),
          Variable.withInt(limit),
        ],
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

  Stream<DaySummary> watchSummary(
    DateTime startUtc,
    DateTime endUtc, {
    String? createdBy,
  }) => _db
      .customSelect(
        '''
SELECT type, COUNT(*) AS c, SUM(amount_paisa) AS vol,
       SUM(commission_paisa) AS comm
FROM txn
WHERE status = 'active' AND occurred_at >= ? AND occurred_at < ?
  AND (? IS NULL OR created_by = ?)
GROUP BY type''',
        variables: [
          Variable.withInt(startUtc.millisecondsSinceEpoch),
          Variable.withInt(endUtc.millisecondsSinceEpoch),
          Variable<String>(createdBy),
          Variable<String>(createdBy),
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

  /// Numbers served at least [minUses] times (most often first, ties by
  /// recency), with the amount and account of their latest entry. [type]
  /// null covers cash out, cash in and flexiload. [createdBy] limits the
  /// history to one user's entries (staff see only their own).
  Future<List<RegularCustomer>> regulars({
    TransactionType? type,
    String? createdBy,
    int minUses = 2,
    int limit = 8,
  }) async {
    final types = type == null
        ? const [
            TransactionType.cashOut,
            TransactionType.cashIn,
            TransactionType.flexiload,
          ]
        : [type];
    final marks = List.filled(types.length, '?').join(',');
    final rows = await _db
        .customSelect(
          '''
SELECT t.customer_number AS number, t.type AS type,
       t.amount_paisa AS last_amount, g.c AS uses, g.last AS last_at,
       (SELECT le.account_id FROM ledger_entry le
          JOIN account a ON a.id = le.account_id
         WHERE le.txn_id = t.id AND a.kind IN ('wallet', 'load')
         ORDER BY le.line_no LIMIT 1) AS account_id,
       (SELECT c.name FROM customer c WHERE c.phone = t.customer_number
         LIMIT 1) AS customer_name
FROM txn t
JOIN (
  SELECT customer_number, type, COUNT(*) AS c, MAX(occurred_at) AS last
  FROM txn
  WHERE status = 'active' AND customer_number IS NOT NULL
    AND customer_number <> '' AND type IN ($marks)
    AND (? IS NULL OR created_by = ?)
  GROUP BY customer_number, type
  HAVING COUNT(*) >= ?
) g ON g.customer_number = t.customer_number AND g.type = t.type
   AND g.last = t.occurred_at
WHERE t.status = 'active' AND (? IS NULL OR t.created_by = ?)
GROUP BY t.customer_number, t.type
ORDER BY g.c DESC, g.last DESC
LIMIT ?''',
          variables: [
            ...types.map((t) => Variable.withString(t.dbName)),
            Variable<String>(createdBy),
            Variable<String>(createdBy),
            Variable.withInt(minUses),
            Variable<String>(createdBy),
            Variable<String>(createdBy),
            Variable.withInt(limit),
          ],
          readsFrom: _reads,
        )
        .get();
    return [
      for (final r in rows)
        RegularCustomer(
          number: r.read<String>('number'),
          type: TransactionType.fromDb(r.read<String>('type')),
          lastAmount: Money.paisa(r.read<int>('last_amount')),
          uses: r.read<int>('uses'),
          lastAt: DateTime.fromMillisecondsSinceEpoch(
            r.read<int>('last_at'),
            isUtc: true,
          ),
          accountId: r.readNullable<String>('account_id'),
          name: r.readNullable<String>('customer_name'),
        ),
    ];
  }
}
