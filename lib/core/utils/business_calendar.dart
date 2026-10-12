/// Maps instants to the shop's business date.
///
/// Bangladesh is UTC+6 all year (no DST). A configurable [rolloverHour]
/// (e.g. 4) lets transactions made just after midnight count toward the
/// previous business day.
class BusinessCalendar {
  const BusinessCalendar({this.rolloverHour = 0})
    : assert(rolloverHour >= 0 && rolloverHour < 24);

  static const dhakaOffset = Duration(hours: 6);

  final int rolloverHour;

  /// Wall-clock time in Dhaka, as a UTC-flagged DateTime (fields are Dhaka
  /// local time; do not treat it as a real UTC instant).
  static DateTime dhakaWallClock(DateTime instant) =>
      instant.toUtc().add(dhakaOffset);

  /// `YYYY-MM-DD` of the business day [instant] belongs to.
  String businessDateOf(DateTime instant) {
    final shifted = dhakaWallClock(instant)
        .subtract(Duration(hours: rolloverHour));
    final m = shifted.month.toString().padLeft(2, '0');
    final d = shifted.day.toString().padLeft(2, '0');
    return '${shifted.year.toString().padLeft(4, '0')}-$m-$d';
  }
}
