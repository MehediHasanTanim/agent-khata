import 'package:drift/drift.dart';

import '../../core/audit/audit_logger.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_settings.dart';
import '../../core/ledger/account.dart';
import '../../core/ledger/posting_strategy.dart';
import '../../core/ledger/strategies.dart';
import '../../core/ledger/transaction_draft.dart';
import '../../core/utils/business_calendar.dart';
import '../../core/utils/uuid_v7.dart';
import '../accounts/account_repository.dart';

/// The transaction's business day has been closed.
class DayLockedException implements Exception {
  const DayLockedException(this.businessDate);

  final String businessDate;

  @override
  String toString() => 'DayLockedException: $businessDate is closed';
}

/// Writes business events as one atomic DB transaction: `txn` row, balanced
/// `ledger_entry` rows, and an audit record.
class TransactionRepository {
  TransactionRepository({
    required this._db,
    required this._registry,
    required this._ids,
    required this._audit,
    required this._deviceId,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final PostingRegistry _registry;
  final IdGenerator _ids;
  final AuditLogger _audit;
  final String _deviceId;
  final DateTime Function() _clock;

  /// Validates and records [draft]. Returns the new transaction id.
  ///
  /// Throws [PostingException] for invalid drafts and [DayLockedException]
  /// when the draft's business day is closed.
  Future<String> post(TransactionDraft draft) {
    return _db.transaction(() async {
      final accounts = await _loadResolver(draft);
      final strategy = _registry.strategyFor(draft.type);
      final entries = strategy.post(draft, accounts);

      await _ensureDayOpen(draft.occurredAt);

      final id = _ids.next();
      final now = _clock().toUtc().millisecondsSinceEpoch;
      await _db
          .into(_db.txns)
          .insert(
            TxnsCompanion.insert(
              id: id,
              type: draft.type.dbName,
              occurredAt: draft.occurredAt.toUtc().millisecondsSinceEpoch,
              recordedAt: now,
              amountPaisa: draft.amount.paisa,
              chargePaisa: Value(draft.charge.paisa),
              commissionPaisa: Value(draft.commission.paisa),
              commissionRuleId: Value(draft.commissionRuleId),
              commissionOverridden: Value(draft.commissionOverridden),
              customerId: Value(draft.customerId),
              customerNumber: Value(draft.customerNumber),
              reference: Value(draft.reference),
              note: Value(draft.note),
              createdBy: draft.createdBy,
              shiftId: Value(draft.shiftId),
              deviceId: _deviceId,
            ),
          );
      for (var i = 0; i < entries.length; i++) {
        await _db
            .into(_db.ledgerEntries)
            .insert(
              LedgerEntriesCompanion.insert(
                id: _ids.next(),
                txnId: id,
                accountId: entries[i].accountId,
                deltaPaisa: entries[i].deltaPaisa,
                lineNo: i,
              ),
            );
      }
      await _audit.log(
        userId: draft.createdBy,
        action: 'txn_create',
        entity: 'txn',
        entityId: id,
        after: {
          'type': draft.type.dbName,
          'amount_paisa': draft.amount.paisa,
          'charge_paisa': draft.charge.paisa,
          'commission_paisa': draft.commission.paisa,
          'from': draft.fromAccountId,
          'to': draft.toAccountId,
        },
      );
      return id;
    });
  }

  /// Voids a transaction: the entries stay but no longer count toward
  /// balances. Nothing is deleted.
  Future<void> voidTransaction(
    String txnId, {
    required String reason,
    required String userId,
  }) {
    if (reason.trim().isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'a reason is required');
    }
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.txns,
      )..where((t) => t.id.equals(txnId))).getSingleOrNull();
      if (row == null) throw StateError('Unknown transaction $txnId');
      if (row.status == 'void') {
        throw StateError('Transaction $txnId is already void');
      }
      if (row.dayCloseId != null) {
        final dc = await (_db.select(
          _db.dayCloses,
        )..where((t) => t.id.equals(row.dayCloseId!))).getSingle();
        if (dc.status != 'reopened') {
          throw DayLockedException(dc.businessDate);
        }
      }
      final now = _clock().toUtc().millisecondsSinceEpoch;
      await (_db.update(_db.txns)..where((t) => t.id.equals(txnId))).write(
        TxnsCompanion(
          status: const Value('void'),
          voidReason: Value(reason),
          voidedAt: Value(now),
        ),
      );
      await _audit.log(
        userId: userId,
        action: 'txn_void',
        entity: 'txn',
        entityId: txnId,
        before: {'status': 'active'},
        after: {'status': 'void'},
        reason: reason,
      );
    });
  }

  Future<AccountResolver> _loadResolver(TransactionDraft draft) async {
    final ids = {
      if (draft.fromAccountId != null) draft.fromAccountId!,
      if (draft.toAccountId != null) draft.toAccountId!,
      kExternalAccountId,
    };
    final rows = await (_db.select(
      _db.accounts,
    )..where((t) => t.id.isIn(ids))).get();
    return MapAccountResolver(rows.map(AccountRepository.fromRow));
  }

  Future<void> _ensureDayOpen(DateTime occurredAt) async {
    final hour = await DbSettings(_db).dayRolloverHour();
    final date = BusinessCalendar(rolloverHour: hour)
        .businessDateOf(occurredAt);
    final closed =
        await (_db.select(_db.dayCloses)..where(
              (t) => t.businessDate.equals(date) & t.status.equals('closed'),
            ))
            .getSingleOrNull();
    if (closed != null) throw DayLockedException(date);
  }
}
