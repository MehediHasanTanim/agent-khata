import '../transactions/history_queries.dart';

/// CSV of transactions for spreadsheets (Excel and Google Sheets open it).
///
/// UTF-8 with a BOM so Excel reads Bangla text correctly, ASCII digits so
/// numbers stay numbers, times in Dhaka, and cells that could be read as a
/// formula are prefixed with an apostrophe.
class TransactionCsv {
  const TransactionCsv._();

  static const header = [
    'date',
    'time',
    'type',
    'account',
    'customer',
    'customer_number',
    'amount',
    'charge',
    'commission',
    'trx_id',
    'note',
    'status',
    'void_reason',
  ];

  static String build(Iterable<HistoryItem> items) {
    final out = StringBuffer('﻿')..write(_row(header));
    for (final i in items) {
      final dhaka = i.occurredAt.toUtc().add(const Duration(hours: 6));
      out.write(
        _row([
          '${_p4(dhaka.year)}-${_p2(dhaka.month)}-${_p2(dhaka.day)}',
          '${_p2(dhaka.hour)}:${_p2(dhaka.minute)}',
          i.type.dbName,
          i.accountLabel ?? '',
          i.customerName ?? '',
          i.customerNumber ?? '',
          _taka(i.amount.paisa),
          _taka(i.charge.paisa),
          _taka(i.commission.paisa),
          i.reference ?? '',
          i.note ?? '',
          i.isVoid ? 'void' : 'active',
          i.voidReason ?? '',
        ]),
      );
    }
    return out.toString();
  }

  static String _row(List<String> cells) => '${cells.map(_cell).join(',')}\r\n';

  static String _cell(String raw) {
    var v = raw;
    if (v.isNotEmpty && '=+-@\t\r'.contains(v[0])) v = "'$v";
    if (v.contains(',') ||
        v.contains('"') ||
        v.contains('\n') ||
        v.contains('\r')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  static String _taka(int paisa) {
    final whole = paisa ~/ 100;
    final frac = paisa % 100;
    return frac == 0 ? '$whole' : '$whole.${frac.toString().padLeft(2, '0')}';
  }

  static String _p2(int n) => n.toString().padLeft(2, '0');
  static String _p4(int n) => n.toString().padLeft(4, '0');
}

/// Splits [items] into pages of [perPage] (the last may be shorter).
List<List<T>> paginate<T>(List<T> items, int perPage) {
  if (perPage <= 0) throw ArgumentError.value(perPage, 'perPage');
  return [
    for (var i = 0; i < items.length; i += perPage)
      items.sublist(i, i + perPage > items.length ? items.length : i + perPage),
  ];
}
