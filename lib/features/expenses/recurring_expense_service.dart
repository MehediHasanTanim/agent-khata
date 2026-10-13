import 'package:drift/drift.dart';

import '../../core/audit/audit_logger.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_settings.dart';
import '../../core/ledger/transaction_draft.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/security/roles.dart';
import '../../core/utils/business_calendar.dart';
import '../../core/utils/uuid_v7.dart';
import '../transactions/transaction_repository.dart';
import 'recurrence.dart';

class RecurringException implements Exception {
  const RecurringException(this.code);

  /// `not_found`, `not_positive`, `inactive`.
  final String code;

  @override
  String toString() => 'RecurringException($code)';
}

class RecurringExpense {
  const RecurringExpense({
    required this.id,
    required this.categoryAccountId,
    required this.sourceAccountId,
    required this.amount,
    required this.recurrence,
    required this.nextDueDate,
    required this.isActive,
    this.note,
    this.categoryLabel,
    this.sourceLabel,
  });

  final String id;
  final String categoryAccountId;
  final String sourceAccountId;
  final Money amount;
  final Recurrence recurrence;
  final String nextDueDate;
  final bool isActive;
  final String? note;
  final String? categoryLabel;
  final String? sourceLabel;
}

/// Reminders for expenses that repeat. Nothing is posted until the agent
/// confirms an occurrence, so a changed rent or a skipped month never
/// creates a wrong entry.
class RecurringExpenseService {
  RecurringExpenseService({
    required this._db,
    required this._txns,
    required this._audit,
    required this._ids,
    DateTime Function()? clock,
    this._session,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final TransactionRepository _txns;
  final AuditLogger _audit;
  final IdGenerator _ids;
  final DateTime Function() _clock;
  final SessionReader? _session;

  Future<String> todayBusinessDate() async {
    final hour = await DbSettings(_db).dayRolloverHour();
    return BusinessCalendar(rolloverHour: hour)
        .businessDateOf(_clock().toUtc());
  }

  static const _selectSql = '''
SELECT r.*, c.label AS category_label, s.label AS source_label
FROM recurring_expense r
JOIN account c ON c.id = r.category_account_id
JOIN account s ON s.id = r.source_account_id''';

  static RecurringExpense _from(QueryRow row) {
    final frequency = RecurrenceFrequency.fromDb(row.read<String>('frequency'));
    final day = frequency == RecurrenceFrequency.monthly
        ? row.read<int>('day_of_month')
        : row.read<int>('weekday');
    return RecurringExpense(
      id: row.read<String>('id'),
      categoryAccountId: row.read<String>('category_account_id'),
      sourceAccountId: row.read<String>('source_account_id'),
      amount: Money.paisa(row.read<int>('amount_paisa')),
      recurrence: frequency == RecurrenceFrequency.monthly
          ? Recurrence.monthly(day)
          : Recurrence.weekly(day),
      nextDueDate: row.read<String>('next_due_date'),
      isActive: row.read<int>('is_active') == 1,
      note: row.readNullable<String>('note'),
      categoryLabel: row.readNullable<String>('category_label'),
      sourceLabel: row.readNullable<String>('source_label'),
    );
  }

  Set<ResultSetImplementation<dynamic, dynamic>> get _reads => {
    _db.recurringExpenses,
    _db.accounts,
  };

  Stream<List<RecurringExpense>> watchAll() => _db
      .customSelect(
        '$_selectSql ORDER BY r.is_active DESC, r.next_due_date, r.created_at',
        readsFrom: _reads,
      )
      .watch()
      .map((rows) => rows.map(_from).toList());

  Future<RecurringExpense?> byId(String id) async {
    final rows = await _db
        .customSelect(
          '$_selectSql WHERE r.id = ?',
          variables: [Variable.withString(id)],
          readsFrom: _reads,
        )
        .get();
    return rows.isEmpty ? null : _from(rows.first);
  }

  /// Active templates whose next occurrence is on or before today.
  Future<List<RecurringExpense>> due() async {
    final today = await todayBusinessDate();
    final rows = await _db
        .customSelect(
          '$_selectSql WHERE r.is_active = 1 AND r.next_due_date <= ? '
          'ORDER BY r.next_due_date, r.created_at',
          variables: [Variable.withString(today)],
          readsFrom: _reads,
        )
        .get();
    return rows.map(_from).toList();
  }

  Future<String> create({
    required String categoryAccountId,
    required String sourceAccountId,
    required Money amount,
    required Recurrence recurrence,
    String? note,
  }) async {
    requirePermission(_session, Permission.manageSettings);
    if (!amount.isPositive) throw const RecurringException('not_positive');
    final today = await todayBusinessDate();
    final id = _ids.next();
    await _db
        .into(_db.recurringExpenses)
        .insert(
          RecurringExpensesCompanion.insert(
            id: id,
            categoryAccountId: categoryAccountId,
            sourceAccountId: sourceAccountId,
            amountPaisa: amount.paisa,
            frequency: recurrence.frequency.dbName,
            dayOfMonth: Value(
              recurrence.frequency == RecurrenceFrequency.monthly
                  ? recurrence.day
                  : null,
            ),
            weekday: Value(
              recurrence.frequency == RecurrenceFrequency.weekly
                  ? recurrence.day
                  : null,
            ),
            nextDueDate: recurrence.firstOnOrAfter(today),
            note: Value(note),
            createdAt: _clock().toUtc().millisecondsSinceEpoch,
          ),
        );
    return id;
  }

  Future<void> update(
    String id, {
    Money? amount,
    Recurrence? recurrence,
    String? categoryAccountId,
    String? sourceAccountId,
    String? note,
    bool? isActive,
  }) async {
    requirePermission(_session, Permission.manageSettings);
    if (amount != null && !amount.isPositive) {
      throw const RecurringException('not_positive');
    }
    final today = await todayBusinessDate();
    final n =
        await (_db.update(
          _db.recurringExpenses,
        )..where((t) => t.id.equals(id))).write(
          RecurringExpensesCompanion(
            amountPaisa: amount == null
                ? const Value.absent()
                : Value(amount.paisa),
            categoryAccountId: categoryAccountId == null
                ? const Value.absent()
                : Value(categoryAccountId),
            sourceAccountId: sourceAccountId == null
                ? const Value.absent()
                : Value(sourceAccountId),
            note: note == null ? const Value.absent() : Value(note),
            isActive: isActive == null ? const Value.absent() : Value(isActive),
            frequency: recurrence == null
                ? const Value.absent()
                : Value(recurrence.frequency.dbName),
            dayOfMonth: recurrence == null
                ? const Value.absent()
                : Value(
                    recurrence.frequency == RecurrenceFrequency.monthly
                        ? recurrence.day
                        : null,
                  ),
            weekday: recurrence == null
                ? const Value.absent()
                : Value(
                    recurrence.frequency == RecurrenceFrequency.weekly
                        ? recurrence.day
                        : null,
                  ),
            nextDueDate: recurrence == null
                ? const Value.absent()
                : Value(recurrence.firstOnOrAfter(today)),
          ),
        );
    if (n == 0) throw const RecurringException('not_found');
  }

  /// Records one occurrence as an expense and moves the template to its
  /// next date. Returns the expense transaction id.
  Future<String> record(String id, {String userId = kOwnerUserId}) async {
    return _db.transaction(() async {
      final r = await byId(id);
      if (r == null) throw const RecurringException('not_found');
      if (!r.isActive) throw const RecurringException('inactive');
      final txnId = await _txns.post(
        TransactionDraft(
          type: TransactionType.expense,
          occurredAt: _clock().toUtc(),
          amount: r.amount,
          fromAccountId: r.sourceAccountId,
          toAccountId: r.categoryAccountId,
          note: r.note == null ? 'recurring' : 'recurring: ${r.note}',
          createdBy: userId,
        ),
      );
      await _advance(r);
      await _audit.log(
        userId: userId,
        action: 'recurring_record',
        entity: 'recurring_expense',
        entityId: id,
        after: {'due': r.nextDueDate, 'txn': txnId},
      );
      return txnId;
    });
  }

  /// Moves past this occurrence without recording anything.
  Future<void> skip(String id, {String userId = kOwnerUserId}) async {
    await _db.transaction(() async {
      final r = await byId(id);
      if (r == null) throw const RecurringException('not_found');
      await _advance(r);
      await _audit.log(
        userId: userId,
        action: 'recurring_skip',
        entity: 'recurring_expense',
        entityId: id,
        after: {'due': r.nextDueDate},
      );
    });
  }

  Future<void> _advance(RecurringExpense r) async {
    await (_db.update(
      _db.recurringExpenses,
    )..where((t) => t.id.equals(r.id))).write(
      RecurringExpensesCompanion(
        nextDueDate: Value(r.recurrence.nextAfter(r.nextDueDate)),
      ),
    );
  }
}
