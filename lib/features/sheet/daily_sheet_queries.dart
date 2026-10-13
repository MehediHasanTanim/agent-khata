import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';

/// One line of the drawer (cash account) for the printed sheet.
class CashSheetLine {
  const CashSheetLine({
    required this.occurredAt,
    required this.type,
    required this.delta,
    required this.balance,
    required this.isVoid,
    this.counterparty,
    this.customerNumber,
    this.note,
  });

  final DateTime occurredAt;
  final TransactionType type;

  /// Signed effect on the cash drawer.
  final Money delta;

  /// Drawer balance after this line (unchanged by voided lines).
  final Money balance;
  final bool isVoid;

  /// The wallet, operator, category or bank on the other side.
  final String? counterparty;
  final String? customerNumber;
  final String? note;
}

class CashSheetData {
  const CashSheetData({
    required this.cashAccountLabel,
    required this.opening,
    required this.closing,
    required this.lines,
  });

  final String cashAccountLabel;

  /// Drawer balance at the start of the period.
  final Money opening;

  /// Drawer balance at the end of the period.
  final Money closing;
  final List<CashSheetLine> lines;
}

/// The cash drawer's movements for `[start, end)`, oldest first, with the
/// balance running over the whole history so opening is exact.
class DailySheetQueries {
  DailySheetQueries(this._db);

  final AppDatabase _db;

  Future<CashSheetData?> cash(DateTime start, DateTime end) async {
    final cash =
        await (_db.select(_db.accounts)
              ..where((a) => a.kind.equals('cash') & a.isActive.equals(true))
              ..orderBy([(a) => OrderingTerm.asc(a.sortOrder)])
              ..limit(1))
            .getSingleOrNull();
    if (cash == null) return null;
    final startMs = start.toUtc().millisecondsSinceEpoch;
    final endMs = end.toUtc().millisecondsSinceEpoch;

    // Balance before the period: opening + active entries before `start`.
    final before = await _db
        .customSelect(
          '''
SELECT COALESCE(SUM(le.delta_paisa), 0) AS s
FROM ledger_entry le JOIN txn t ON t.id = le.txn_id
WHERE le.account_id = ? AND t.status = 'active' AND t.occurred_at < ?''',
          variables: [Variable.withString(cash.id), Variable.withInt(startMs)],
          readsFrom: {_db.ledgerEntries, _db.txns},
        )
        .getSingle();
    final opening = cash.openingPaisa + before.read<int>('s');

    final rows = await _db
        .customSelect(
          '''
SELECT t.type, t.status, t.occurred_at, t.customer_number, t.note,
       le.delta_paisa,
       (SELECT a2.label FROM ledger_entry le2
          JOIN account a2 ON a2.id = le2.account_id
         WHERE le2.txn_id = t.id AND le2.account_id <> le.account_id
           AND a2.kind IN ('wallet', 'load', 'expense', 'bank', 'receivable',
                           'payable')
         ORDER BY le2.line_no LIMIT 1) AS counterparty
FROM ledger_entry le JOIN txn t ON t.id = le.txn_id
WHERE le.account_id = ? AND t.occurred_at >= ? AND t.occurred_at < ?
ORDER BY t.occurred_at, t.recorded_at, le.id''',
          variables: [
            Variable.withString(cash.id),
            Variable.withInt(startMs),
            Variable.withInt(endMs),
          ],
          readsFrom: {_db.ledgerEntries, _db.txns, _db.accounts},
        )
        .get();

    var running = opening;
    final lines = <CashSheetLine>[];
    for (final r in rows) {
      final isVoid = r.read<String>('status') == 'void';
      final delta = r.read<int>('delta_paisa');
      if (!isVoid) running += delta;
      lines.add(
        CashSheetLine(
          occurredAt: DateTime.fromMillisecondsSinceEpoch(
            r.read<int>('occurred_at'),
            isUtc: true,
          ),
          type: TransactionType.fromDb(r.read<String>('type')),
          delta: Money.paisa(delta),
          balance: Money.paisa(running),
          isVoid: isVoid,
          counterparty: r.readNullable<String>('counterparty'),
          customerNumber: r.readNullable<String>('customer_number'),
          note: r.readNullable<String>('note'),
        ),
      );
    }
    return CashSheetData(
      cashAccountLabel: cash.label,
      opening: Money.paisa(opening),
      closing: Money.paisa(running),
      lines: lines,
    );
  }
}
