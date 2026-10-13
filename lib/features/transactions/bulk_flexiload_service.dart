import '../../core/db/app_database.dart';
import '../../core/ledger/transaction_draft.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../entry/bulk_flexiload.dart';
import 'transaction_repository.dart';

/// Several flexiload sales for one operator, saved together.
class BulkFlexiloadService {
  BulkFlexiloadService(this._db, this._txns);

  final AppDatabase _db;
  final TransactionRepository _txns;

  /// Posts every complete row in [rows] as its own flexiload entry, inside a
  /// single database transaction: either all are saved or none. [marginFor]
  /// gives the margin for a price (from the commission engine).
  ///
  /// Returns the new transaction ids in row order. Blank rows are skipped;
  /// a row with a number but no amount throws [ArgumentError].
  Future<List<String>> save({
    required String operatorAccountId,
    required String cashAccountId,
    required List<BulkRow> rows,
    required Money Function(Money price) marginFor,
    required String createdBy,
    String? commissionRuleId,
    DateTime? at,
  }) async {
    final toSave = [
      for (final r in rows)
        if (!r.isBlank) r,
    ];
    for (final r in toSave) {
      if (!r.isComplete) {
        throw ArgumentError.value(r.number, 'rows', 'row has no amount');
      }
    }
    if (toSave.isEmpty) return const [];

    final now = (at ?? DateTime.now()).toUtc();
    return _db.transaction(() async {
      final ids = <String>[];
      for (final r in toSave) {
        final number = normalizeMobile(r.number);
        ids.add(
          await _txns.post(
            TransactionDraft(
              type: TransactionType.flexiload,
              occurredAt: now,
              amount: r.amount!,
              fromAccountId: operatorAccountId,
              toAccountId: cashAccountId,
              commission: marginFor(r.amount!),
              commissionRuleId: commissionRuleId,
              customerNumber: number.isEmpty ? null : number,
              createdBy: createdBy,
            ),
          ),
        );
      }
      return ids;
    });
  }

  /// Voids every entry of a batch (the "undo" for a bulk save).
  Future<void> voidAll(
    List<String> ids, {
    required String userId,
    String reason = 'undo',
  }) {
    return _db.transaction(() async {
      for (final id in ids) {
        await _txns.voidTransaction(id, reason: reason, userId: userId);
      }
    });
  }
}
