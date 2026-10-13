import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';

/// Customer-facing transaction types: what "an entry" means for insights.
/// Expenses, adjustments, dues and float moves are not sales.
const insightTypes = [
  TransactionType.cashIn,
  TransactionType.cashOut,
  TransactionType.flexiload,
  TransactionType.sendMoney,
  TransactionType.billPay,
];

class HourStat {
  const HourStat({
    required this.hour,
    required this.count,
    required this.profit,
    required this.volume,
  });

  /// Clock hour in Dhaka, 0-23.
  final int hour;
  final int count;

  /// Commission plus flexiload margin earned on entries in this hour.
  final Money profit;
  final Money volume;
}

class WeekdayStat {
  const WeekdayStat({
    required this.weekday,
    required this.count,
    required this.profit,
    required this.activeDays,
  });

  /// 1 = Monday ... 7 = Sunday.
  final int weekday;
  final int count;
  final Money profit;

  /// Distinct business days with at least one entry on this weekday.
  final int activeDays;

  /// Average profit on a day that had entries.
  Money get profitPerDay =>
      activeDays == 0 ? Money.zero : profit.mulRatio(1, activeDays);
}

class TypeAverage {
  const TypeAverage({
    required this.type,
    required this.count,
    required this.average,
  });

  final TransactionType type;
  final int count;
  final Money average;
}

class Insights {
  const Insights({
    required this.count,
    required this.averageSize,
    required this.byType,
    required this.hours,
    required this.weekdays,
  });

  /// Number of customer entries in the period.
  final int count;

  /// Mean amount across all of them.
  final Money averageSize;
  final List<TypeAverage> byType;

  /// Always 24 items, hour 0 to 23.
  final List<HourStat> hours;

  /// Always 7 items, Monday to Sunday.
  final List<WeekdayStat> weekdays;

  /// Enough entries to say anything meaningful.
  bool get hasEnoughData => count >= 10;

  HourStat? get busiestHour => _best(hours, (h) => h.count);
  HourStat? get mostProfitableHour =>
      _best(hours, (h) => h.profit.paisa, requirePositive: true);

  WeekdayStat? get bestWeekday {
    WeekdayStat? best;
    for (final w in weekdays) {
      if (w.activeDays == 0) continue;
      if (best == null || w.profitPerDay > best.profitPerDay) best = w;
    }
    return best == null || !best.profitPerDay.isPositive ? null : best;
  }

  static T? _best<T>(
    List<T> items,
    int Function(T) score, {
    bool requirePositive = false,
  }) {
    T? best;
    var top = 0;
    for (final i in items) {
      final s = score(i);
      if (s > top) {
        top = s;
        best = i;
      }
    }
    if (best == null && !requirePositive) return null;
    return best;
  }
}

/// Aggregates for the Insights section of Reports.
class InsightsQueries {
  InsightsQueries(this._db);

  final AppDatabase _db;

  Future<Insights> compute(
    DateTime start,
    DateTime end, {
    int rolloverHour = 0,
  }) async {
    final startMs = start.toUtc().millisecondsSinceEpoch;
    final endMs = end.toUtc().millisecondsSinceEpoch;
    final marks = List.filled(insightTypes.length, '?').join(',');
    final typeVars = [
      for (final t in insightTypes) Variable.withString(t.dbName),
    ];
    const hourShift = 6 * 3600; // Dhaka clock time
    final dayShift = (6 - rolloverHour) * 3600; // business day

    final hourRows = await _db
        .customSelect(
          '''
SELECT CAST(strftime('%H', occurred_at / 1000 + ?, 'unixepoch') AS INTEGER) AS h,
       COUNT(*) AS c,
       COALESCE(SUM(commission_paisa), 0) AS profit,
       COALESCE(SUM(amount_paisa), 0) AS vol
FROM txn
WHERE status = 'active' AND occurred_at >= ? AND occurred_at < ?
  AND type IN ($marks)
GROUP BY h''',
          variables: [
            Variable.withInt(hourShift),
            Variable.withInt(startMs),
            Variable.withInt(endMs),
            ...typeVars,
          ],
          readsFrom: {_db.txns},
        )
        .get();
    final byHour = {for (final r in hourRows) r.read<int>('h'): r};
    final hours = [
      for (var h = 0; h < 24; h++)
        HourStat(
          hour: h,
          count: byHour[h]?.read<int>('c') ?? 0,
          profit: Money.paisa(byHour[h]?.read<int>('profit') ?? 0),
          volume: Money.paisa(byHour[h]?.read<int>('vol') ?? 0),
        ),
    ];

    final dayRows = await _db
        .customSelect(
          '''
SELECT CAST(strftime('%w', occurred_at / 1000 + ?, 'unixepoch') AS INTEGER) AS w,
       COUNT(*) AS c,
       COALESCE(SUM(commission_paisa), 0) AS profit,
       COUNT(DISTINCT strftime('%Y-%m-%d', occurred_at / 1000 + ?, 'unixepoch')) AS days
FROM txn
WHERE status = 'active' AND occurred_at >= ? AND occurred_at < ?
  AND type IN ($marks)
GROUP BY w''',
          variables: [
            Variable.withInt(dayShift),
            Variable.withInt(dayShift),
            Variable.withInt(startMs),
            Variable.withInt(endMs),
            ...typeVars,
          ],
          readsFrom: {_db.txns},
        )
        .get();
    // SQLite %w: 0 = Sunday. Convert to 1 = Monday ... 7 = Sunday.
    final byWeekday = {
      for (final r in dayRows)
        (r.read<int>('w') == 0 ? 7 : r.read<int>('w')): r,
    };
    final weekdays = [
      for (var d = 1; d <= 7; d++)
        WeekdayStat(
          weekday: d,
          count: byWeekday[d]?.read<int>('c') ?? 0,
          profit: Money.paisa(byWeekday[d]?.read<int>('profit') ?? 0),
          activeDays: byWeekday[d]?.read<int>('days') ?? 0,
        ),
    ];

    final typeRows = await _db
        .customSelect(
          '''
SELECT type, COUNT(*) AS c, COALESCE(SUM(amount_paisa), 0) AS vol
FROM txn
WHERE status = 'active' AND occurred_at >= ? AND occurred_at < ?
  AND type IN ($marks)
GROUP BY type ORDER BY c DESC''',
          variables: [
            Variable.withInt(startMs),
            Variable.withInt(endMs),
            ...typeVars,
          ],
          readsFrom: {_db.txns},
        )
        .get();
    var total = 0;
    var volume = 0;
    final byType = <TypeAverage>[];
    for (final r in typeRows) {
      final c = r.read<int>('c');
      final v = r.read<int>('vol');
      total += c;
      volume += v;
      byType.add(
        TypeAverage(
          type: TransactionType.fromDb(r.read<String>('type')),
          count: c,
          average: Money.paisa(v).mulRatio(1, c),
        ),
      );
    }

    return Insights(
      count: total,
      averageSize: total == 0
          ? Money.zero
          : Money.paisa(volume).mulRatio(1, total),
      byType: byType,
      hours: hours,
      weekdays: weekdays,
    );
  }
}
