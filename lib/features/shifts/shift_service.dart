import 'package:drift/drift.dart';

import '../../core/audit/audit_logger.dart';
import '../../core/db/app_database.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/ledger/transaction_draft.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../closeday/day_close_service.dart';
import '../closeday/reconciliation_engine.dart';
import '../transactions/transaction_repository.dart';

class ShiftException implements Exception {
  const ShiftException(this.code);

  /// `no_open_shift`.
  final String code;

  @override
  String toString() => 'ShiftException($code)';
}

class ShiftInfo {
  const ShiftInfo({
    required this.id,
    required this.userId,
    required this.startedAt,
    required this.isOpen,
    this.userName,
    this.endedAt,
    this.totalVariance,
  });

  final String id;
  final String userId;
  final String? userName;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isOpen;

  /// Sum of per-account variances at handover (closed shifts only).
  final Money? totalVariance;
}

class ShiftSummary {
  const ShiftSummary({
    required this.count,
    required this.cashInVolume,
    required this.cashOutVolume,
    required this.commission,
    required this.flexiloadMargin,
    required this.expenses,
  });

  final int count;
  final Money cashInVolume;
  final Money cashOutVolume;
  final Money commission;
  final Money flexiloadMargin;
  final Money expenses;

  Money get netProfit => commission + flexiloadMargin - expenses;
}

class OperatorVariance {
  const OperatorVariance({
    required this.userId,
    required this.shifts,
    required this.total,
    required this.shortage,
  });

  final String userId;
  final int shifts;

  /// Net of shortages and excesses.
  final Money total;

  /// Sum of the negative variances only (what went missing).
  final Money shortage;
}

/// Shift handovers: count the drawer and wallets when one operator hands
/// over to the next, attribute the difference to the operator who held the
/// shift, and carry the counted figures forward.
class ShiftService {
  ShiftService({
    required this._db,
    required this._txns,
    required this._audit,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final TransactionRepository _txns;
  final AuditLogger _audit;
  final DateTime Function() _clock;

  Future<ShiftRow?> currentOpen() =>
      (_db.select(_db.shifts)
            ..where((t) => t.status.equals('open'))
            ..limit(1))
          .getSingleOrNull();

  Stream<ShiftInfo?> watchOpen() =>
      (_db.select(_db.shifts)
            ..where((t) => t.status.equals('open'))
            ..limit(1))
          .watchSingleOrNull()
          .asyncMap((r) async => r == null ? null : await _info(r));

  Future<ShiftInfo> _info(ShiftRow r) async {
    final user = await (_db.select(
      _db.appUsers,
    )..where((t) => t.id.equals(r.userId))).getSingleOrNull();
    int? variance;
    if (r.status == 'closed') {
      final v = await _db
          .customSelect(
            'SELECT COALESCE(SUM(variance_paisa), 0) AS v FROM shift_line '
            'WHERE shift_id = ?',
            variables: [Variable.withString(r.id)],
            readsFrom: {_db.shiftLines},
          )
          .getSingle();
      variance = v.read<int>('v');
    }
    return ShiftInfo(
      id: r.id,
      userId: r.userId,
      userName: user?.name,
      startedAt: DateTime.fromMillisecondsSinceEpoch(r.startedAt, isUtc: true),
      endedAt: r.endedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(r.endedAt!, isUtc: true),
      isOpen: r.status == 'open',
      totalVariance: variance == null ? null : Money.paisa(variance),
    );
  }

  /// Expected balance of every active counted account right now.
  Future<
    List<({String accountId, String label, AccountKind kind, Money expected})>
  >
  expectedNow() async {
    final counted = countedKinds.map((k) => k.dbName).toList();
    final rows = await _db
        .customSelect(
          '''
SELECT a.id, a.label, a.kind,
       a.opening_paisa + COALESCE((
         SELECT SUM(le.delta_paisa) FROM ledger_entry le
         JOIN txn t ON t.id = le.txn_id
         WHERE le.account_id = a.id AND t.status = 'active'), 0) AS balance
FROM account a
WHERE a.is_active = 1 AND a.kind IN (${List.filled(counted.length, '?').join(',')})
ORDER BY a.sort_order, a.created_at''',
          variables: counted.map(Variable.withString).toList(),
          readsFrom: {_db.accounts, _db.ledgerEntries, _db.txns},
        )
        .get();
    return [
      for (final r in rows)
        (
          accountId: r.read<String>('id'),
          label: r.read<String>('label'),
          kind: AccountKind.fromDb(r.read<String>('kind')),
          expected: Money.paisa(r.read<int>('balance')),
        ),
    ];
  }

  /// Entries of the open shift on counted accounts (for gap hints).
  Future<List<DayEntry>> entriesOf(String shiftId) async {
    final counted = countedKinds.map((k) => k.dbName).toList();
    final rows = await _db
        .customSelect(
          '''
SELECT t.id, t.type, t.occurred_at, le.account_id, le.delta_paisa
FROM ledger_entry le JOIN txn t ON t.id = le.txn_id
JOIN account a ON a.id = le.account_id
WHERE t.status = 'active' AND t.shift_id = ?
  AND a.kind IN (${List.filled(counted.length, '?').join(',')})
ORDER BY t.occurred_at, t.id''',
          variables: [
            Variable.withString(shiftId),
            ...counted.map(Variable.withString),
          ],
          readsFrom: {_db.ledgerEntries, _db.txns, _db.accounts},
        )
        .get();
    return [
      for (final r in rows)
        DayEntry(
          txnId: r.read<String>('id'),
          type: TransactionType.fromDb(r.read<String>('type')),
          occurredAt: DateTime.fromMillisecondsSinceEpoch(
            r.read<int>('occurred_at'),
            isUtc: true,
          ),
          accountId: r.read<String>('account_id'),
          deltaPaisa: r.read<int>('delta_paisa'),
        ),
    ];
  }

  /// Ends the open shift with a count. Variances beyond [toleranceTaka] need
  /// a reason in [resolutions]; each is posted as an adjustment so the books
  /// agree with the count from this moment on. Returns the closed shift id.
  Future<String> handover({
    required Map<String, Money> actuals,
    Map<String, VarianceResolution> resolutions = const {},
    int toleranceTaka = 0,
    required String userId,
    String? note,
  }) {
    return _db.transaction(() async {
      final shift = await currentOpen();
      if (shift == null) throw const ShiftException('no_open_shift');
      final now = _clock().toUtc();
      final tolerance = Money.taka(toleranceTaka);
      final expected = await expectedNow();

      final lines = <_ShiftLine>[];
      for (final e in expected) {
        final actual = actuals[e.accountId] ?? e.expected;
        final variance = actual - e.expected;
        String? adjustmentId;
        if (!variance.isZero) {
          final r = variance.abs() <= tolerance
              ? const VarianceResolution(AdjustmentReason.tolerance)
              : resolutions[e.accountId];
          if (r == null) throw MissingVarianceReason(e.accountId);
          adjustmentId = await _txns.post(
            TransactionDraft(
              type: TransactionType.adjustment,
              occurredAt: now,
              amount: variance.abs(),
              toAccountId: variance.isPositive ? e.accountId : null,
              fromAccountId: variance.isNegative ? e.accountId : null,
              note: r.text == null || r.text!.trim().isEmpty
                  ? r.reason.code
                  : '${r.reason.code}: ${r.text!.trim()}',
              createdBy: userId,
              shiftId: shift.id,
            ),
            internal: true,
          );
        }
        lines.add(
          _ShiftLine(e.accountId, e.expected, actual, variance, adjustmentId),
        );
      }

      for (final l in lines) {
        await _db
            .into(_db.shiftLines)
            .insert(
              ShiftLinesCompanion.insert(
                shiftId: shift.id,
                accountId: l.accountId,
                expectedPaisa: l.expected.paisa,
                actualPaisa: l.actual.paisa,
                variancePaisa: l.variance.paisa,
                adjustmentTxnId: Value(l.adjustmentTxnId),
              ),
            );
      }
      await (_db.update(_db.shifts)..where((t) => t.id.equals(shift.id))).write(
        ShiftsCompanion(
          status: const Value('closed'),
          endedAt: Value(now.millisecondsSinceEpoch),
          note: Value(note),
        ),
      );
      await _audit.log(
        userId: userId,
        action: 'shift_handover',
        entity: 'shift',
        entityId: shift.id,
        after: {
          'operator': shift.userId,
          'total_variance_paisa': lines.fold<int>(
            0,
            (s, l) => s + l.variance.paisa,
          ),
        },
      );
      return shift.id;
    });
  }

  /// Closes the open shift (if any) using figures already counted by the day
  /// close, so the final shift of the day carries the day's variance.
  /// Called inside the day-close transaction.
  Future<void> closeWithDayClose({
    required List<
      ({
        String accountId,
        Money expected,
        Money actual,
        Money variance,
        String? adjustmentTxnId,
      })
    >
    lines,
    required DateTime at,
  }) async {
    final shift = await currentOpen();
    if (shift == null) return;
    for (final l in lines) {
      await _db
          .into(_db.shiftLines)
          .insert(
            ShiftLinesCompanion.insert(
              shiftId: shift.id,
              accountId: l.accountId,
              expectedPaisa: l.expected.paisa,
              actualPaisa: l.actual.paisa,
              variancePaisa: l.variance.paisa,
              adjustmentTxnId: Value(l.adjustmentTxnId),
            ),
          );
    }
    await (_db.update(_db.shifts)..where((t) => t.id.equals(shift.id))).write(
      ShiftsCompanion(
        status: const Value('closed'),
        endedAt: Value(at.millisecondsSinceEpoch),
      ),
    );
  }

  /// Totals for the entries tagged with [shiftId].
  Future<ShiftSummary> summary(String shiftId) async {
    final rows = await _db
        .customSelect(
          '''
SELECT type, COUNT(*) AS c, COALESCE(SUM(amount_paisa), 0) AS vol,
       COALESCE(SUM(commission_paisa), 0) AS comm
FROM txn WHERE status = 'active' AND shift_id = ? AND type <> 'adjustment'
GROUP BY type''',
          variables: [Variable.withString(shiftId)],
          readsFrom: {_db.txns},
        )
        .get();
    var count = 0;
    var cashIn = 0;
    var cashOut = 0;
    var commission = 0;
    var margin = 0;
    var expenses = 0;
    for (final r in rows) {
      final type = TransactionType.fromDb(r.read<String>('type'));
      count += r.read<int>('c');
      final vol = r.read<int>('vol');
      final comm = r.read<int>('comm');
      switch (type) {
        case TransactionType.cashIn:
          cashIn += vol;
          commission += comm;
        case TransactionType.cashOut:
          cashOut += vol;
          commission += comm;
        case TransactionType.flexiload:
          margin += comm;
        case TransactionType.expense:
          expenses += vol;
        default:
          commission += comm;
      }
    }
    return ShiftSummary(
      count: count,
      cashInVolume: Money.paisa(cashIn),
      cashOutVolume: Money.paisa(cashOut),
      commission: Money.paisa(commission),
      flexiloadMargin: Money.paisa(margin),
      expenses: Money.paisa(expenses),
    );
  }

  /// Recent shifts, newest first. [userId] limits to one operator.
  Future<List<ShiftInfo>> recent({int limit = 30, String? userId}) async {
    final rows =
        await (_db.select(_db.shifts)
              ..where(
                (t) => userId == null
                    ? const Constant(true)
                    : t.userId.equals(userId),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
              ..limit(limit))
            .get();
    return [for (final r in rows) await _info(r)];
  }

  /// Per-operator totals of closed-shift variances in `[start, end)`.
  Future<List<OperatorVariance>> varianceByOperator(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _db
        .customSelect(
          '''
SELECT s.user_id, COUNT(DISTINCT s.id) AS shifts,
       COALESCE(SUM(l.variance_paisa), 0) AS total,
       COALESCE(SUM(CASE WHEN l.variance_paisa < 0
                         THEN l.variance_paisa ELSE 0 END), 0) AS shortage
FROM shift s LEFT JOIN shift_line l ON l.shift_id = s.id
WHERE s.status = 'closed' AND s.started_at >= ? AND s.started_at < ?
GROUP BY s.user_id
ORDER BY shortage''',
          variables: [
            Variable.withInt(start.toUtc().millisecondsSinceEpoch),
            Variable.withInt(end.toUtc().millisecondsSinceEpoch),
          ],
          readsFrom: {_db.shifts, _db.shiftLines},
        )
        .get();
    return [
      for (final r in rows)
        OperatorVariance(
          userId: r.read<String>('user_id'),
          shifts: r.read<int>('shifts'),
          total: Money.paisa(r.read<int>('total')),
          shortage: Money.paisa(r.read<int>('shortage')),
        ),
    ];
  }
}

class _ShiftLine {
  const _ShiftLine(
    this.accountId,
    this.expected,
    this.actual,
    this.variance,
    this.adjustmentTxnId,
  );

  final String accountId;
  final Money expected;
  final Money actual;
  final Money variance;
  final String? adjustmentTxnId;
}
