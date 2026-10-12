import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';
import '../../core/ledger/transaction_type.dart';
import 'commission_rule.dart';

class CommissionRuleRepository {
  CommissionRuleRepository(this._db);

  final AppDatabase _db;

  static CommissionRule fromRow(CommissionRuleRow r) => CommissionRule(
    id: r.id,
    provider: r.provider,
    txnType: TransactionType.fromDb(r.txnType),
    mode: CommissionMode.fromDb(r.mode),
    value: r.value,
    effectiveFrom: DateTime.fromMillisecondsSinceEpoch(
      r.effectiveFrom,
      isUtc: true,
    ),
    effectiveTo: r.effectiveTo == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(r.effectiveTo!, isUtc: true),
  );

  Future<void> insert(CommissionRule rule) => _db
      .into(_db.commissionRules)
      .insert(
        CommissionRulesCompanion.insert(
          id: rule.id,
          provider: rule.provider,
          txnType: rule.txnType.dbName,
          mode: rule.mode.dbName,
          value: rule.value,
          effectiveFrom: rule.effectiveFrom.toUtc().millisecondsSinceEpoch,
          effectiveTo: Value(rule.effectiveTo?.toUtc().millisecondsSinceEpoch),
        ),
      );

  Future<List<CommissionRule>> all() async =>
      (await _db.select(_db.commissionRules).get()).map(fromRow).toList();
}
