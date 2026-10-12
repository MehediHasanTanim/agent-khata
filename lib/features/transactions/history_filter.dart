import 'package:drift/drift.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';

/// What the history list shows. All fields optional.
class HistoryFilter {
  const HistoryFilter({
    this.from,
    this.to,
    this.types = const {},
    this.accountId,
    this.query = '',
    this.includeVoid = true,
  });

  /// UTC, inclusive.
  final DateTime? from;

  /// UTC, exclusive.
  final DateTime? to;
  final Set<TransactionType> types;
  final String? accountId;

  /// Free text: amount, customer number/name, note or TrxID.
  final String query;
  final bool includeVoid;

  HistoryFilter copyWith({
    DateTime? from,
    DateTime? to,
    bool clearRange = false,
    Set<TransactionType>? types,
    String? accountId,
    bool clearAccount = false,
    String? query,
    bool? includeVoid,
  }) => HistoryFilter(
    from: clearRange ? null : (from ?? this.from),
    to: clearRange ? null : (to ?? this.to),
    types: types ?? this.types,
    accountId: clearAccount ? null : (accountId ?? this.accountId),
    query: query ?? this.query,
    includeVoid: includeVoid ?? this.includeVoid,
  );
}

/// Keyset position: continue after this (occurredAt, id), newest first.
class HistoryCursor {
  const HistoryCursor(this.occurredAtMs, this.id);

  final int occurredAtMs;
  final String id;
}

class BuiltQuery {
  const BuiltQuery(this.where, this.variables);

  /// SQL fragment starting with `WHERE`, or empty.
  final String where;
  final List<Variable<Object>> variables;
}

String _escapeLike(String s) =>
    s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

/// Builds the WHERE clause (table aliases: `t` = txn, `c` = customer).
BuiltQuery buildHistoryWhere(HistoryFilter f, {HistoryCursor? cursor}) {
  final clauses = <String>[];
  final vars = <Variable<Object>>[];

  if (!f.includeVoid) clauses.add("t.status = 'active'");
  if (f.from != null) {
    clauses.add('t.occurred_at >= ?');
    vars.add(Variable.withInt(f.from!.toUtc().millisecondsSinceEpoch));
  }
  if (f.to != null) {
    clauses.add('t.occurred_at < ?');
    vars.add(Variable.withInt(f.to!.toUtc().millisecondsSinceEpoch));
  }
  if (f.types.isNotEmpty) {
    clauses.add('t.type IN (${List.filled(f.types.length, '?').join(',')})');
    vars.addAll(f.types.map((t) => Variable.withString(t.dbName)));
  }
  if (f.accountId != null) {
    clauses.add(
      'EXISTS (SELECT 1 FROM ledger_entry le '
      'WHERE le.txn_id = t.id AND le.account_id = ?)',
    );
    vars.add(Variable.withString(f.accountId!));
  }

  final q = DigitFormatter.toLatin(f.query).trim();
  if (q.isNotEmpty) {
    final like = '%${_escapeLike(q)}%';
    final parts = <String>[
      r"t.customer_number LIKE ? ESCAPE '\'",
      r"t.reference LIKE ? ESCAPE '\'",
      r"t.note LIKE ? ESCAPE '\'",
      r"c.name LIKE ? ESCAPE '\'",
      r"c.phone LIKE ? ESCAPE '\'",
    ];
    vars.addAll(List.filled(5, Variable.withString(like)));
    final asAmount = Money.tryParse(q);
    if (asAmount != null && asAmount.isPositive) {
      parts.add('t.amount_paisa = ?');
      vars.add(Variable.withInt(asAmount.paisa));
    }
    clauses.add('(${parts.join(' OR ')})');
  }

  if (cursor != null) {
    clauses.add('(t.occurred_at < ? OR (t.occurred_at = ? AND t.id < ?))');
    vars
      ..add(Variable.withInt(cursor.occurredAtMs))
      ..add(Variable.withInt(cursor.occurredAtMs))
      ..add(Variable.withString(cursor.id));
  }

  return BuiltQuery(
    clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}',
    vars,
  );
}
