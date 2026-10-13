import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';

class TypeTotals {
  const TypeTotals({
    required this.count,
    required this.volume,
    required this.commission,
  });

  final int count;
  final Money volume;
  final Money commission;
}

class DayPoint {
  const DayPoint({
    required this.businessDate,
    required this.net,
    required this.count,
  });

  final String businessDate;

  /// Commission + flexiload margin - expenses for the day.
  final Money net;
  final int count;
}

class ReportSummary {
  const ReportSummary({
    required this.count,
    required this.cashInVolume,
    required this.cashOutVolume,
    required this.commission,
    required this.flexiloadMargin,
    required this.expenses,
    required this.perType,
    required this.daily,
  });

  final int count;
  final Money cashInVolume;
  final Money cashOutVolume;

  /// Commission on cash in/out (excludes flexiload margin).
  final Money commission;
  final Money flexiloadMargin;
  final Money expenses;
  final Map<TransactionType, TypeTotals> perType;
  final List<DayPoint> daily;

  Money get netProfit => commission + flexiloadMargin - expenses;
}

class VariancePoint {
  const VariancePoint(this.businessDate, this.variance);

  final String businessDate;
  final Money variance;
}

/// Net variance of one account across recent closed days.
class AccountVariance {
  const AccountVariance({
    required this.accountId,
    required this.label,
    required this.total,
    required this.shortage,
    required this.excess,
    required this.daysWithDifference,
    required this.closedDays,
  });

  final String accountId;
  final String label;

  /// Net of shortages and excesses.
  final Money total;

  /// Sum of the negative daily variances (<= 0).
  final Money shortage;

  /// Sum of the positive daily variances (>= 0).
  final Money excess;
  final int daysWithDifference;
  final int closedDays;
}

/// How closed days of one weekday tend to come out.
class WeekdayVariance {
  const WeekdayVariance({
    required this.weekday,
    required this.closedDays,
    required this.shortDays,
    required this.shortage,
    required this.net,
  });

  /// 1 = Monday ... 7 = Sunday.
  final int weekday;
  final int closedDays;

  /// Closed days of this weekday whose total was negative.
  final int shortDays;

  /// Sum of the negative day totals (<= 0).
  final Money shortage;
  final Money net;

  /// Average day total (net / closedDays).
  Money get averageNet =>
      closedDays == 0 ? Money.zero : net.mulRatio(1, closedDays);
}

class CommissionComparison {
  const CommissionComparison({
    required this.provider,
    required this.expected,
    required this.received,
  });

  final String provider;

  /// Commission calculated on cash in/out for this provider.
  final Money expected;

  /// Commission the provider has credited (recorded by the agent).
  final Money received;

  /// Still to be credited; negative means more was received than expected.
  Money get pending => expected - received;
}

/// Read-only aggregate queries behind the Reports tab.
class ReportQueries {
  ReportQueries(this._db);

  final AppDatabase _db;

  /// Totals for `[start, end)` plus a per-business-day net series.
  /// [rolloverHour] decides which business day a night sale belongs to.
  Future<ReportSummary> summary(
    DateTime start,
    DateTime end, {
    int rolloverHour = 0,
  }) async {
    final startMs = start.toUtc().millisecondsSinceEpoch;
    final endMs = end.toUtc().millisecondsSinceEpoch;

    final byType = await _db
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
    final perType = <TransactionType, TypeTotals>{};
    for (final r in byType) {
      final type = TransactionType.fromDb(r.read<String>('type'));
      final c = r.read<int>('c');
      final vol = r.read<int>('vol');
      final comm = r.read<int>('comm');
      count += c;
      perType[type] = TypeTotals(
        count: c,
        volume: Money.paisa(vol),
        commission: Money.paisa(comm),
      );
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

    // Business date = Dhaka (UTC+6) date after removing the rollover hour.
    final shiftSeconds = (6 - rolloverHour) * 3600;
    final dayRows = await _db
        .customSelect(
          '''
SELECT strftime('%Y-%m-%d', occurred_at / 1000 + ?, 'unixepoch') AS d,
       SUM(CASE WHEN type = 'expense' THEN -amount_paisa
                ELSE commission_paisa END) AS net,
       COUNT(*) AS c
FROM txn
WHERE status = 'active' AND occurred_at >= ? AND occurred_at < ?
  AND type <> 'adjustment'
GROUP BY d ORDER BY d''',
          variables: [
            Variable.withInt(shiftSeconds),
            Variable.withInt(startMs),
            Variable.withInt(endMs),
          ],
          readsFrom: {_db.txns},
        )
        .get();

    return ReportSummary(
      count: count,
      cashInVolume: Money.paisa(cashIn),
      cashOutVolume: Money.paisa(cashOut),
      commission: Money.paisa(commission),
      flexiloadMargin: Money.paisa(margin),
      expenses: Money.paisa(expenses),
      perType: perType,
      daily: [
        for (final r in dayRows)
          DayPoint(
            businessDate: r.read<String>('d'),
            net: Money.paisa(r.read<int>('net')),
            count: r.read<int>('c'),
          ),
      ],
    );
  }

  /// Total variance of each closed day, oldest first (up to [limit] most
  /// recent days).
  ///
  /// With [accountId] only that account's variance is counted.
  Future<List<VariancePoint>> varianceHistory({
    int limit = 30,
    String? accountId,
  }) async {
    final rows = await _db
        .customSelect(
          '''
SELECT business_date, variance FROM (
  SELECT d.business_date AS business_date,
         COALESCE(SUM(l.variance_paisa), 0) AS variance
  FROM day_close d
  LEFT JOIN day_close_line l
    ON l.day_close_id = d.id AND (? IS NULL OR l.account_id = ?)
  WHERE d.status = 'closed'
  GROUP BY d.id
  ORDER BY d.business_date DESC
  LIMIT ?
) ORDER BY business_date''',
          variables: [
            Variable<String>(accountId),
            Variable<String>(accountId),
            Variable.withInt(limit),
          ],
          readsFrom: {_db.dayCloses, _db.dayCloseLines},
        )
        .get();
    return [
      for (final r in rows)
        VariancePoint(
          r.read<String>('business_date'),
          Money.paisa(r.read<int>('variance')),
        ),
    ];
  }

  /// Per-account totals over the [limit] most recent closed days. Accounts
  /// with the largest shortage come first.
  Future<List<AccountVariance>> varianceByAccount({int limit = 30}) async {
    final rows = await _db
        .customSelect(
          '''
WITH recent AS (
  SELECT id FROM day_close WHERE status = 'closed'
  ORDER BY business_date DESC LIMIT ?
)
SELECT a.id AS account_id, a.label AS label,
       COALESCE(SUM(l.variance_paisa), 0) AS total,
       COALESCE(SUM(CASE WHEN l.variance_paisa < 0
                         THEN l.variance_paisa ELSE 0 END), 0) AS shortage,
       COALESCE(SUM(CASE WHEN l.variance_paisa > 0
                         THEN l.variance_paisa ELSE 0 END), 0) AS excess,
       COALESCE(SUM(CASE WHEN l.variance_paisa <> 0 THEN 1 ELSE 0 END), 0)
         AS diff_days,
       COUNT(l.day_close_id) AS closed_days
FROM day_close_line l
JOIN recent r ON r.id = l.day_close_id
JOIN account a ON a.id = l.account_id
GROUP BY a.id
ORDER BY shortage, a.label''',
          variables: [Variable.withInt(limit)],
          readsFrom: {_db.dayCloses, _db.dayCloseLines, _db.accounts},
        )
        .get();
    return [
      for (final r in rows)
        AccountVariance(
          accountId: r.read<String>('account_id'),
          label: r.read<String>('label'),
          total: Money.paisa(r.read<int>('total')),
          shortage: Money.paisa(r.read<int>('shortage')),
          excess: Money.paisa(r.read<int>('excess')),
          daysWithDifference: r.read<int>('diff_days'),
          closedDays: r.read<int>('closed_days'),
        ),
    ];
  }

  /// Day totals of the [limit] most recent closed days, grouped by the
  /// weekday of the business date (always 7 items, Monday first).
  Future<List<WeekdayVariance>> varianceByWeekday({int limit = 90}) async {
    final days = await varianceHistory(limit: limit);
    final closed = List.filled(8, 0);
    final short = List.filled(8, 0);
    final shortage = List.filled(8, 0);
    final net = List.filled(8, 0);
    for (final d in days) {
      final p = d.businessDate.split('-').map(int.parse).toList();
      final wd = DateTime.utc(p[0], p[1], p[2]).weekday;
      closed[wd]++;
      net[wd] += d.variance.paisa;
      if (d.variance.isNegative) {
        short[wd]++;
        shortage[wd] += d.variance.paisa;
      }
    }
    return [
      for (var wd = 1; wd <= 7; wd++)
        WeekdayVariance(
          weekday: wd,
          closedDays: closed[wd],
          shortDays: short[wd],
          shortage: Money.paisa(shortage[wd]),
          net: Money.paisa(net[wd]),
        ),
    ];
  }

  /// Expected vs credited commission per provider for `[start, end)`.
  /// Pass a wide range (or null bounds) for "since the beginning".
  Future<List<CommissionComparison>> commissionComparison({
    DateTime? start,
    DateTime? end,
  }) async {
    final startMs = start?.toUtc().millisecondsSinceEpoch;
    final endMs = end?.toUtc().millisecondsSinceEpoch;
    final rows = await _db
        .customSelect(
          '''
SELECT a.provider AS provider,
       COALESCE(SUM(CASE WHEN t.type IN ('cash_in', 'cash_out')
                         THEN t.commission_paisa ELSE 0 END), 0) AS expected,
       COALESCE(SUM(CASE WHEN t.type = 'commission_received'
                         THEN t.amount_paisa ELSE 0 END), 0) AS received
FROM txn t
JOIN ledger_entry le ON le.txn_id = t.id
JOIN account a ON a.id = le.account_id AND a.kind = 'wallet'
WHERE t.status = 'active' AND a.provider IS NOT NULL
  AND t.type IN ('cash_in', 'cash_out', 'commission_received')
  AND (? IS NULL OR t.occurred_at >= ?)
  AND (? IS NULL OR t.occurred_at < ?)
GROUP BY a.provider
ORDER BY a.provider''',
          variables: [
            Variable<int>(startMs),
            Variable<int>(startMs),
            Variable<int>(endMs),
            Variable<int>(endMs),
          ],
          readsFrom: {_db.txns, _db.ledgerEntries, _db.accounts},
        )
        .get();
    return [
      for (final r in rows)
        CommissionComparison(
          provider: r.read<String>('provider'),
          expected: Money.paisa(r.read<int>('expected')),
          received: Money.paisa(r.read<int>('received')),
        ),
    ];
  }
}
