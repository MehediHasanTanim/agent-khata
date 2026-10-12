import 'package:drift/drift.dart';

import '../../core/audit/audit_logger.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_settings.dart';
import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/ledger/transaction_draft.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/utils/business_calendar.dart';
import '../../core/utils/uuid_v7.dart';
import '../accounts/account_repository.dart';
import '../transactions/transaction_repository.dart';
import 'reconciliation_engine.dart';

/// Why a residual variance was written off. Stored as the adjustment note.
enum AdjustmentReason {
  shortage('shortage'),
  excess('excess'),
  providerCharge('provider_charge'),
  countingError('counting_error'),
  tolerance('tolerance'),
  other('other');

  const AdjustmentReason(this.code);
  final String code;

  static AdjustmentReason? fromNote(String? note) {
    if (note == null) return null;
    for (final r in values) {
      if (note == r.code || note.startsWith('${r.code}:')) return r;
    }
    return null;
  }
}

class VarianceResolution {
  const VarianceResolution(this.reason, {this.text});

  final AdjustmentReason reason;
  final String? text;
}

class AccountExpectation {
  const AccountExpectation(this.account, this.expected);

  final Account account;
  final Money expected;
}

class CloseDayPreview {
  const CloseDayPreview({
    required this.businessDate,
    required this.start,
    required this.end,
    required this.accounts,
    required this.entries,
    this.status,
  });

  final String businessDate;
  final DateTime start;
  final DateTime end;
  final List<AccountExpectation> accounts;
  final List<DayEntry> entries;

  /// `closed`, `reopened`, or null when never closed.
  final String? status;
}

class ClosedDay {
  const ClosedDay({
    required this.id,
    required this.businessDate,
    required this.status,
    required this.totalVariance,
    this.closedAt,
  });

  final String id;
  final String businessDate;
  final String status;
  final Money totalVariance;
  final DateTime? closedAt;
}

/// Per-account row of the daily summary.
class SummaryAccountLine {
  const SummaryAccountLine({
    required this.label,
    required this.opening,
    required this.moneyIn,
    required this.moneyOut,
    required this.expected,
    this.actual,
  });

  final String label;
  final Money opening;
  final Money moneyIn;
  final Money moneyOut;
  final Money expected;

  /// Null until the day has been closed with counts.
  final Money? actual;

  Money? get variance => actual == null ? null : actual! - expected;
}

/// Everything shown on (and shared from) the daily summary.
class DailySummaryData {
  const DailySummaryData({
    required this.businessDate,
    required this.status,
    required this.count,
    required this.cashInVolume,
    required this.cashOutVolume,
    required this.commission,
    required this.flexiloadMargin,
    required this.expenses,
    required this.accounts,
    this.totalVariance,
  });

  final String businessDate;

  /// `closed`, `reopened` or null (not closed yet).
  final String? status;
  final int count;
  final Money cashInVolume;
  final Money cashOutVolume;

  /// Provider commission on cash-in/out and similar (excludes flexiload).
  final Money commission;
  final Money flexiloadMargin;
  final Money expenses;
  final List<SummaryAccountLine> accounts;
  final Money? totalVariance;

  /// Commission + flexiload margin - expenses.
  Money get netProfit => commission + flexiloadMargin - expenses;
}

class MissingVarianceReason implements Exception {
  const MissingVarianceReason(this.accountId);

  final String accountId;

  @override
  String toString() => 'MissingVarianceReason($accountId)';
}

class DayCloseException implements Exception {
  const DayCloseException(this.code);

  final String code;

  @override
  String toString() => 'DayCloseException($code)';
}

/// Day close, reopen and the queries behind them.
class DayCloseService {
  DayCloseService({
    required this._db,
    required this._txns,
    required this._audit,
    required this._ids,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final TransactionRepository _txns;
  final AuditLogger _audit;
  final IdGenerator _ids;
  final DateTime Function() _clock;

  Future<BusinessCalendar> _calendar() async =>
      BusinessCalendar(rolloverHour: await DbSettings(_db).dayRolloverHour());

  /// Expected balances and the day's entries for [businessDate].
  Future<CloseDayPreview> preview(String businessDate) async {
    final range = (await _calendar()).rangeOfDate(businessDate);
    final endMs = range.end.millisecondsSinceEpoch;
    final startMs = range.start.millisecondsSinceEpoch;

    final counted = countedKinds.map((k) => k.dbName).toList();
    final accountRows =
        await (_db.select(_db.accounts)
              ..where((a) => a.kind.isIn(counted) & a.isActive.equals(true))
              ..orderBy([
                (a) => OrderingTerm.asc(a.sortOrder),
                (a) => OrderingTerm.asc(a.createdAt),
              ]))
            .get();

    final sums = await _db
        .customSelect(
          '''
SELECT le.account_id, SUM(le.delta_paisa) AS s
FROM ledger_entry le JOIN txn t ON t.id = le.txn_id
WHERE t.status = 'active' AND t.occurred_at < ?
GROUP BY le.account_id''',
          variables: [Variable.withInt(endMs)],
          readsFrom: {_db.ledgerEntries, _db.txns},
        )
        .get();
    final sumBy = {
      for (final r in sums) r.read<String>('account_id'): r.read<int>('s'),
    };

    final entryRows = await _db
        .customSelect(
          '''
SELECT t.id, t.type, t.occurred_at, le.account_id, le.delta_paisa
FROM ledger_entry le JOIN txn t ON t.id = le.txn_id
JOIN account a ON a.id = le.account_id
WHERE t.status = 'active' AND t.occurred_at >= ? AND t.occurred_at < ?
  AND a.kind IN (${List.filled(counted.length, '?').join(',')})
ORDER BY t.occurred_at, t.id''',
          variables: [
            Variable.withInt(startMs),
            Variable.withInt(endMs),
            ...counted.map(Variable.withString),
          ],
          readsFrom: {_db.ledgerEntries, _db.txns, _db.accounts},
        )
        .get();

    final existing = await (_db.select(
      _db.dayCloses,
    )..where((t) => t.businessDate.equals(businessDate))).getSingleOrNull();

    return CloseDayPreview(
      businessDate: businessDate,
      start: range.start,
      end: range.end,
      status: existing?.status,
      accounts: [
        for (final a in accountRows)
          AccountExpectation(
            AccountRepository.fromRow(a),
            Money.paisa(a.openingPaisa + (sumBy[a.id] ?? 0)),
          ),
      ],
      entries: [
        for (final r in entryRows)
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
      ],
    );
  }

  /// Closes [businessDate]. Idempotent: closing a closed day returns its id.
  ///
  /// [actuals] holds the counted balance per account id; accounts missing
  /// from it are taken as matching the books. Any variance beyond
  /// [toleranceTaka] needs an entry in [resolutions]; within tolerance it is
  /// written off automatically.
  Future<String> close({
    required String businessDate,
    required Map<String, Money> actuals,
    Map<String, VarianceResolution> resolutions = const {},
    int toleranceTaka = 0,
    String userId = 'owner',
    String? note,
  }) {
    return _db.transaction(() async {
      final existing = await (_db.select(
        _db.dayCloses,
      )..where((t) => t.businessDate.equals(businessDate))).getSingleOrNull();
      if (existing != null && existing.status == 'closed') return existing.id;

      final preview = await this.preview(businessDate);
      final now = _clock().toUtc();
      if (preview.start.isAfter(now)) {
        throw const DayCloseException('future_day');
      }
      final tolerance = Money.taka(toleranceTaka);
      final lines = <_Line>[];
      final adjustmentAt = now.isBefore(preview.end)
          ? now
          : preview.end.subtract(const Duration(seconds: 1));

      for (final e in preview.accounts) {
        final actual = actuals[e.account.id] ?? e.expected;
        final variance = actual - e.expected;
        String? adjustmentId;
        if (!variance.isZero) {
          final withinTolerance = variance.abs() <= tolerance;
          final r = withinTolerance
              ? const VarianceResolution(AdjustmentReason.tolerance)
              : resolutions[e.account.id];
          if (r == null) throw MissingVarianceReason(e.account.id);
          adjustmentId = await _txns.post(
            TransactionDraft(
              type: TransactionType.adjustment,
              occurredAt: adjustmentAt,
              amount: variance.abs(),
              toAccountId: variance.isPositive ? e.account.id : null,
              fromAccountId: variance.isNegative ? e.account.id : null,
              note: r.text == null || r.text!.trim().isEmpty
                  ? r.reason.code
                  : '${r.reason.code}: ${r.text!.trim()}',
              createdBy: userId,
            ),
          );
        }
        lines.add(
          _Line(e.account.id, e.expected, actual, variance, adjustmentId),
        );
      }

      final id = existing?.id ?? _ids.next();
      final nowMs = now.millisecondsSinceEpoch;
      await _db
          .into(_db.dayCloses)
          .insert(
            DayClosesCompanion.insert(
              id: id,
              businessDate: businessDate,
              status: 'closed',
              note: Value(note),
              closedBy: Value(userId),
              closedAt: Value(nowMs),
            ),
            mode: InsertMode.insertOrReplace,
          );
      await (_db.delete(
        _db.dayCloseLines,
      )..where((t) => t.dayCloseId.equals(id))).go();
      for (final l in lines) {
        await _db
            .into(_db.dayCloseLines)
            .insert(
              DayCloseLinesCompanion.insert(
                dayCloseId: id,
                accountId: l.accountId,
                expectedPaisa: l.expected.paisa,
                actualPaisa: l.actual.paisa,
                variancePaisa: l.variance.paisa,
                adjustmentTxnId: Value(l.adjustmentTxnId),
              ),
            );
      }

      // Lock every transaction of the day, including the adjustments.
      await _db.customStatement(
        'UPDATE txn SET day_close_id = ? '
        'WHERE day_close_id IS NULL AND occurred_at >= ? AND occurred_at < ?',
        [
          id,
          preview.start.millisecondsSinceEpoch,
          preview.end.millisecondsSinceEpoch,
        ],
      );

      await _writeSnapshots(businessDate, nowMs);

      await _audit.log(
        userId: userId,
        action: 'day_close',
        entity: 'day_close',
        entityId: id,
        after: {
          'business_date': businessDate,
          'total_variance_paisa': lines.fold<int>(
            0,
            (s, l) => s + l.variance.paisa,
          ),
        },
      );
      return id;
    });
  }

  Future<void> _writeSnapshots(String businessDate, int nowMs) async {
    final maxRow = await _db
        .customSelect('SELECT COALESCE(MAX(rowid), 0) AS m FROM txn')
        .getSingle();
    final maxRowid = maxRow.read<int>('m');
    final balances = await _db
        .customSelect(
          '''
SELECT a.id AS account_id,
       a.opening_paisa + COALESCE((
         SELECT SUM(le.delta_paisa) FROM ledger_entry le
         JOIN txn t ON t.id = le.txn_id
         WHERE le.account_id = a.id AND t.status = 'active'), 0) AS balance
FROM account a''',
          readsFrom: {_db.accounts, _db.ledgerEntries, _db.txns},
        )
        .get();
    for (final r in balances) {
      await _db
          .into(_db.balanceSnapshots)
          .insert(
            BalanceSnapshotsCompanion.insert(
              accountId: r.read<String>('account_id'),
              businessDate: businessDate,
              balancePaisa: r.read<int>('balance'),
              maxTxnRowid: maxRowid,
              createdAt: nowMs,
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  /// Reopens the most recent closed day so it can be corrected. The close
  /// adjustments are voided; closing again recomputes them from the counts.
  Future<void> reopen(
    String businessDate, {
    required String reason,
    String userId = 'owner',
  }) {
    if (reason.trim().isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'a reason is required');
    }
    return _db.transaction(() async {
      final dc = await (_db.select(
        _db.dayCloses,
      )..where((t) => t.businessDate.equals(businessDate))).getSingleOrNull();
      if (dc == null || dc.status != 'closed') {
        throw const DayCloseException('not_closed');
      }
      final later =
          await (_db.select(_db.dayCloses)..where(
                (t) =>
                    t.businessDate.isBiggerThanValue(businessDate) &
                    t.status.equals('closed'),
              ))
              .get();
      if (later.isNotEmpty) throw const DayCloseException('later_day_closed');

      await (_db.update(_db.dayCloses)..where((t) => t.id.equals(dc.id))).write(
        DayClosesCompanion(
          status: const Value('reopened'),
          reopenedBy: Value(userId),
          reopenedAt: Value(_clock().toUtc().millisecondsSinceEpoch),
          reopenReason: Value(reason.trim()),
        ),
      );

      final lines = await (_db.select(
        _db.dayCloseLines,
      )..where((t) => t.dayCloseId.equals(dc.id))).get();
      for (final l in lines) {
        final adj = l.adjustmentTxnId;
        if (adj != null) {
          await _txns.voidTransaction(
            adj,
            reason: 'day reopened',
            userId: userId,
          );
        }
      }
      await (_db.delete(
        _db.balanceSnapshots,
      )..where((t) => t.businessDate.equals(businessDate))).go();

      await _audit.log(
        userId: userId,
        action: 'day_reopen',
        entity: 'day_close',
        entityId: dc.id,
        reason: reason.trim(),
      );
    });
  }

  /// Totals and per-account figures for [businessDate].
  Future<DailySummaryData> summary(String businessDate) async {
    final p = await preview(businessDate);
    final startMs = p.start.millisecondsSinceEpoch;
    final endMs = p.end.millisecondsSinceEpoch;

    final rows = await _db
        .customSelect(
          '''
SELECT type, COUNT(*) AS c, COALESCE(SUM(amount_paisa), 0) AS vol,
       COALESCE(SUM(commission_paisa), 0) AS comm
FROM txn
WHERE status = 'active' AND occurred_at >= ? AND occurred_at < ?
  AND type <> 'adjustment'
GROUP BY type''',
          variables: [Variable.withInt(startMs), Variable.withInt(endMs)],
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
      switch (type) {
        case TransactionType.cashIn:
          cashIn += r.read<int>('vol');
          commission += r.read<int>('comm');
        case TransactionType.cashOut:
          cashOut += r.read<int>('vol');
          commission += r.read<int>('comm');
        case TransactionType.flexiload:
          margin += r.read<int>('comm');
        case TransactionType.expense:
          expenses += r.read<int>('vol');
        default:
          commission += r.read<int>('comm');
      }
    }

    final dc = await (_db.select(
      _db.dayCloses,
    )..where((t) => t.businessDate.equals(businessDate))).getSingleOrNull();
    final lines = dc == null
        ? const <DayCloseLineRow>[]
        : await (_db.select(
            _db.dayCloseLines,
          )..where((t) => t.dayCloseId.equals(dc.id))).get();
    final lineBy = {for (final l in lines) l.accountId: l};

    final accountLines = <SummaryAccountLine>[];
    for (final e in p.accounts) {
      var inSum = 0;
      var outSum = 0;
      for (final x in p.entries) {
        if (x.accountId != e.account.id) continue;
        if (x.deltaPaisa > 0) {
          inSum += x.deltaPaisa;
        } else {
          outSum += -x.deltaPaisa;
        }
      }
      final line = lineBy[e.account.id];
      final expected = line == null
          ? e.expected
          : Money.paisa(line.expectedPaisa);
      accountLines.add(
        SummaryAccountLine(
          label: e.account.label,
          opening: Money.paisa(e.expected.paisa - inSum + outSum),
          moneyIn: Money.paisa(inSum),
          moneyOut: Money.paisa(outSum),
          expected: expected,
          actual: line == null ? null : Money.paisa(line.actualPaisa),
        ),
      );
    }

    return DailySummaryData(
      businessDate: businessDate,
      status: dc?.status,
      count: count,
      cashInVolume: Money.paisa(cashIn),
      cashOutVolume: Money.paisa(cashOut),
      commission: Money.paisa(commission),
      flexiloadMargin: Money.paisa(margin),
      expenses: Money.paisa(expenses),
      accounts: accountLines,
      totalVariance: dc == null || dc.status != 'closed'
          ? null
          : Money.paisa(lines.fold<int>(0, (sum, l) => sum + l.variancePaisa)),
    );
  }

  /// Closed and reopened days, newest first.
  Future<List<ClosedDay>> recent({int limit = 30}) async {
    final rows = await _db
        .customSelect(
          '''
SELECT d.id, d.business_date, d.status, d.closed_at,
       COALESCE((SELECT SUM(l.variance_paisa) FROM day_close_line l
                 WHERE l.day_close_id = d.id), 0) AS variance
FROM day_close d ORDER BY d.business_date DESC LIMIT ?''',
          variables: [Variable.withInt(limit)],
          readsFrom: {_db.dayCloses, _db.dayCloseLines},
        )
        .get();
    return [
      for (final r in rows)
        ClosedDay(
          id: r.read<String>('id'),
          businessDate: r.read<String>('business_date'),
          status: r.read<String>('status'),
          totalVariance: Money.paisa(r.read<int>('variance')),
          closedAt: r.readNullable<int>('closed_at') == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(
                  r.read<int>('closed_at'),
                  isUtc: true,
                ),
        ),
    ];
  }
}

class _Line {
  const _Line(
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
