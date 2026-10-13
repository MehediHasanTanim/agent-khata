enum RecurrenceFrequency {
  monthly('monthly'),
  weekly('weekly');

  const RecurrenceFrequency(this.dbName);
  final String dbName;

  static RecurrenceFrequency fromDb(String v) =>
      RecurrenceFrequency.values.firstWhere((f) => f.dbName == v);
}

/// When a recurring expense falls due, on business dates (`YYYY-MM-DD`).
///
/// Monthly rules name a day of the month (1-31); in shorter months the last
/// day is used, and the original day is kept for the following month (a
/// rule for the 31st gives Feb 28, then Mar 31). Weekly rules name a weekday
/// (1 = Monday ... 7 = Sunday).
class Recurrence {
  const Recurrence.monthly(int dayOfMonth)
    : frequency = RecurrenceFrequency.monthly,
      day = dayOfMonth,
      assert(dayOfMonth >= 1 && dayOfMonth <= 31);

  const Recurrence.weekly(int weekday)
    : frequency = RecurrenceFrequency.weekly,
      day = weekday,
      assert(weekday >= 1 && weekday <= 7);

  final RecurrenceFrequency frequency;

  /// Day of month (monthly) or weekday (weekly).
  final int day;

  static DateTime _parse(String date) {
    final p = date.split('-').map(int.parse).toList();
    return DateTime.utc(p[0], p[1], p[2]);
  }

  static String _format(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static int _lastDayOf(int year, int month) =>
      DateTime.utc(year, month + 1, 0).day;

  DateTime _monthlyIn(int year, int month) {
    final y = year + (month - 1) ~/ 12;
    final m = (month - 1) % 12 + 1;
    final d = day > _lastDayOf(y, m) ? _lastDayOf(y, m) : day;
    return DateTime.utc(y, m, d);
  }

  /// The first occurrence on or after [from].
  String firstOnOrAfter(String from) {
    final f = _parse(from);
    switch (frequency) {
      case RecurrenceFrequency.monthly:
        final thisMonth = _monthlyIn(f.year, f.month);
        return _format(
          thisMonth.isBefore(f) ? _monthlyIn(f.year, f.month + 1) : thisMonth,
        );
      case RecurrenceFrequency.weekly:
        final ahead = (day - f.weekday) % 7;
        return _format(f.add(Duration(days: ahead)));
    }
  }

  /// The occurrence after the one on [due].
  String nextAfter(String due) {
    final d = _parse(due);
    switch (frequency) {
      case RecurrenceFrequency.monthly:
        return _format(_monthlyIn(d.year, d.month + 1));
      case RecurrenceFrequency.weekly:
        return _format(d.add(const Duration(days: 7)));
    }
  }

  /// How many occurrences are due on or before [today], starting at
  /// [nextDue] (capped at [cap] so a long gap stays readable).
  int dueCount(String nextDue, String today, {int cap = 12}) {
    var n = 0;
    var d = nextDue;
    while (d.compareTo(today) <= 0 && n < cap) {
      n++;
      d = nextAfter(d);
    }
    return n;
  }
}
