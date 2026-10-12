import 'package:intl/intl.dart';

import 'digit_formatter.dart';

/// Formats instants as Dhaka local date/time using the user's language and
/// digit style. Requires `initializeDateFormatting` for the language.
class DateLabels {
  const DateLabels({required this.languageCode, required this.digits});

  final String languageCode;
  final DigitFormatter digits;

  static const _dhakaOffset = Duration(hours: 6);

  DateTime _dhaka(DateTime instant) => instant.toUtc().add(_dhakaOffset);

  String _fmt(DateFormat f, DateTime instant) =>
      digits.localize(DigitFormatter.toLatin(f.format(_dhaka(instant))));

  /// `20 October 2026` / `২০ অক্টোবর ২০২৬`.
  String day(DateTime instant) =>
      _fmt(DateFormat('d MMMM y', languageCode), instant);

  /// `20 Oct` / `২০ অক্টো`.
  String shortDay(DateTime instant) =>
      _fmt(DateFormat('d MMM', languageCode), instant);

  /// `2:14 PM`.
  String time(DateTime instant) =>
      _fmt(DateFormat('h:mm a', languageCode), instant);

  String dateTime(DateTime instant) => '${shortDay(instant)}, ${time(instant)}';
}
