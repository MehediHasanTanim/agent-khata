import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';
import '../../core/ledger/account.dart';
import '../../core/ledger/transaction_draft.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/utils/uuid_v7.dart';
import '../customers/customer_repository.dart';
import '../transactions/transaction_repository.dart';

enum DueDirection {
  /// The customer owes the agent (baki given).
  theyOwe('they_owe'),

  /// The agent holds the customer's money and owes it back.
  iOwe('i_owe');

  const DueDirection(this.dbName);
  final String dbName;

  static DueDirection fromDb(String v) =>
      DueDirection.values.firstWhere((d) => d.dbName == v);
}

class DueException implements Exception {
  const DueException(this.code);

  /// `not_found`, `already_void`, `over_settle`, `not_positive`.
  final String code;

  @override
  String toString() => 'DueException($code)';
}

class DueView {
  const DueView({
    required this.id,
    required this.customerId,
    required this.direction,
    required this.original,
    required this.settled,
    required this.createdAt,
    required this.isVoid,
    this.customerName,
    this.customerPhone,
    this.note,
  });

  final String id;
  final String customerId;
  final DueDirection direction;
  final Money original;
  final Money settled;
  final DateTime createdAt;
  final bool isVoid;
  final String? customerName;
  final String? customerPhone;
  final String? note;

  Money get remaining => original - settled;
  bool get isOpen => !isVoid && remaining.isPositive;

  String get displayName => (customerName?.isNotEmpty ?? false)
      ? customerName!
      : (customerPhone ?? '');
}

class DueTotals {
  const DueTotals({this.theyOwe = Money.zero, this.iOwe = Money.zero});

  final Money theyOwe;
  final Money iOwe;
}

class SettlementView {
  const SettlementView({
    required this.txnId,
    required this.amount,
    required this.at,
    required this.isVoid,
  });

  final String txnId;
  final Money amount;
  final DateTime at;
  final bool isVoid;
}

/// Customer dues (baki). Every due and every payment is a real ledger
/// transaction, so cash and wallet balances, the day close and backups all
/// stay consistent; the `due` rows only add who owes what.
class DuesService {
  DuesService({
    required this._db,
    required this._txns,
    required this._customers,
    required this._ids,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final TransactionRepository _txns;
  final CustomerRepository _customers;
  final IdGenerator _ids;
  final DateTime Function() _clock;

  /// Records a new due. [accountId] is where the money went from (they owe
  /// me: cash, a wallet or a load account) or where it arrived (I owe).
  Future<String> create({
    required DueDirection direction,
    required Money amount,
    required String accountId,
    String? name,
    String? phone,
    String? note,
    DateTime? at,
    String createdBy = 'owner',
  }) async {
    if (!amount.isPositive) throw const DueException('not_positive');
    return _db.transaction(() async {
      final customerId = await _customers.findOrCreate(
        phone: phone,
        name: name,
      );
      final theyOwe = direction == DueDirection.theyOwe;
      final txnId = await _txns.post(
        TransactionDraft(
          type: theyOwe ? TransactionType.dueGiven : TransactionType.dueTaken,
          occurredAt: at ?? _clock().toUtc(),
          amount: amount,
          fromAccountId: theyOwe ? accountId : kPayableAccountId,
          toAccountId: theyOwe ? kReceivableAccountId : accountId,
          customerId: customerId,
          customerNumber: phone?.trim().isEmpty ?? true ? null : phone!.trim(),
          note: note,
          createdBy: createdBy,
        ),
      );
      final id = _ids.next();
      await _db
          .into(_db.dues)
          .insert(
            DuesCompanion.insert(
              id: id,
              customerId: customerId,
              direction: direction.dbName,
              amountPaisa: amount.paisa,
              createdTxnId: txnId,
              note: Value(note),
              createdAt: _clock().toUtc().millisecondsSinceEpoch,
            ),
          );
      return id;
    });
  }

  /// Records a payment against [dueId]. [accountId] is where the money
  /// arrived (they owe me) or left from (I owe). Returns the transaction id.
  Future<String> settle({
    required String dueId,
    required Money amount,
    required String accountId,
    DateTime? at,
    String createdBy = 'owner',
  }) async {
    if (!amount.isPositive) throw const DueException('not_positive');
    return _db.transaction(() async {
      final due = await byId(dueId);
      if (due == null) throw const DueException('not_found');
      if (due.isVoid) throw const DueException('already_void');
      if (amount > due.remaining) throw const DueException('over_settle');

      final theyOwe = due.direction == DueDirection.theyOwe;
      final txnId = await _txns.post(
        TransactionDraft(
          type: theyOwe ? TransactionType.dueSettled : TransactionType.duePaid,
          occurredAt: at ?? _clock().toUtc(),
          amount: amount,
          fromAccountId: theyOwe ? kReceivableAccountId : accountId,
          toAccountId: theyOwe ? accountId : kPayableAccountId,
          customerId: due.customerId,
          customerNumber: due.customerPhone,
          createdBy: createdBy,
        ),
      );
      await _db
          .into(_db.dueSettlements)
          .insert(
            DueSettlementsCompanion.insert(
              id: _ids.next(),
              dueId: dueId,
              txnId: txnId,
              amountPaisa: amount.paisa,
              createdAt: _clock().toUtc().millisecondsSinceEpoch,
            ),
          );
      return txnId;
    });
  }

  static const _selectSql = '''
SELECT d.id, d.customer_id, d.direction, d.amount_paisa, d.note, d.created_at,
       c.name AS customer_name, c.phone AS customer_phone,
       t.status AS txn_status,
       COALESCE((
         SELECT SUM(s.amount_paisa) FROM due_settlement s
         JOIN txn st ON st.id = s.txn_id
         WHERE s.due_id = d.id AND st.status = 'active'
       ), 0) AS settled
FROM due d
JOIN customer c ON c.id = d.customer_id
JOIN txn t ON t.id = d.created_txn_id''';

  Set<ResultSetImplementation<dynamic, dynamic>> get _reads => {
    _db.dues,
    _db.dueSettlements,
    _db.customers,
    _db.txns,
  };

  static DueView _view(QueryRow r) => DueView(
    id: r.read<String>('id'),
    customerId: r.read<String>('customer_id'),
    direction: DueDirection.fromDb(r.read<String>('direction')),
    original: Money.paisa(r.read<int>('amount_paisa')),
    settled: Money.paisa(r.read<int>('settled')),
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      r.read<int>('created_at'),
      isUtc: true,
    ),
    isVoid: r.read<String>('txn_status') == 'void',
    customerName: r.readNullable<String>('customer_name'),
    customerPhone: r.readNullable<String>('customer_phone'),
    note: r.readNullable<String>('note'),
  );

  Future<DueView?> byId(String id) async {
    final rows = await _db
        .customSelect(
          '$_selectSql WHERE d.id = ?',
          variables: [Variable.withString(id)],
          readsFrom: _reads,
        )
        .get();
    return rows.isEmpty ? null : _view(rows.first);
  }

  /// Open dues (money still owed), newest first, optionally filtered by
  /// customer name or phone.
  Stream<List<DueView>> watchOpen({String query = ''}) {
    final q = query.trim();
    final like =
        '%${q.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    return _db
        .customSelect(
          '''
$_selectSql
WHERE t.status = 'active'
  AND d.amount_paisa > COALESCE((
        SELECT SUM(s.amount_paisa) FROM due_settlement s
        JOIN txn st ON st.id = s.txn_id
        WHERE s.due_id = d.id AND st.status = 'active'), 0)
  ${q.isEmpty ? '' : r"AND (c.name LIKE ? ESCAPE '\' OR c.phone LIKE ? ESCAPE '\')"}
ORDER BY d.created_at DESC, d.id DESC''',
          variables: q.isEmpty
              ? const []
              : [Variable.withString(like), Variable.withString(like)],
          readsFrom: _reads,
        )
        .watch()
        .map((rows) => rows.map(_view).toList());
  }

  Stream<DueTotals> watchTotals() => watchOpen().map((dues) {
    var they = Money.zero;
    var mine = Money.zero;
    for (final d in dues) {
      if (d.direction == DueDirection.theyOwe) {
        they += d.remaining;
      } else {
        mine += d.remaining;
      }
    }
    return DueTotals(theyOwe: they, iOwe: mine);
  });

  Future<List<SettlementView>> settlements(String dueId) async {
    final rows = await _db
        .customSelect(
          '''
SELECT s.txn_id, s.amount_paisa, t.occurred_at, t.status
FROM due_settlement s JOIN txn t ON t.id = s.txn_id
WHERE s.due_id = ? ORDER BY t.occurred_at DESC, s.id DESC''',
          variables: [Variable.withString(dueId)],
          readsFrom: _reads,
        )
        .get();
    return [
      for (final r in rows)
        SettlementView(
          txnId: r.read<String>('txn_id'),
          amount: Money.paisa(r.read<int>('amount_paisa')),
          at: DateTime.fromMillisecondsSinceEpoch(
            r.read<int>('occurred_at'),
            isUtc: true,
          ),
          isVoid: r.read<String>('status') == 'void',
        ),
    ];
  }
}
