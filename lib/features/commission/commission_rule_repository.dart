import 'package:drift/drift.dart';

import '../../core/audit/audit_logger.dart';
import '../../core/db/app_database.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/security/roles.dart';
import '../../core/utils/uuid_v7.dart';
import 'commission_rule.dart';

class CommissionRuleRepository {
  CommissionRuleRepository(this._db, this._ids, this._audit, {this._session});

  final AppDatabase _db;
  final IdGenerator _ids;
  final AuditLogger _audit;
  final SessionReader? _session;

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
    tiers: decodeTiers(r.tiersJson),
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
          tiersJson: Value(rule.tiers.isEmpty ? null : encodeTiers(rule.tiers)),
          effectiveFrom: rule.effectiveFrom.toUtc().millisecondsSinceEpoch,
          effectiveTo: Value(rule.effectiveTo?.toUtc().millisecondsSinceEpoch),
        ),
      );

  Future<List<CommissionRule>> all() async =>
      (await _db.select(_db.commissionRules).get()).map(fromRow).toList();

  Stream<List<CommissionRule>> watchAll() => _db
      .select(_db.commissionRules)
      .watch()
      .map((rows) => rows.map(fromRow).toList());

  /// Sets the rate for [provider] + [type] from [at] onward.
  ///
  /// The currently effective rule is closed at [at] (history is kept) and a
  /// new one starts at [at]. No-op when mode and value are unchanged.
  /// Transactions already saved keep the commission they were saved with.
  Future<void> setRate({
    required String provider,
    required TransactionType type,
    required CommissionMode mode,
    required int value,
    required DateTime at,
    List<CommissionTier> tiers = const [],
    String userId = 'owner',
  }) async {
    requirePermission(_session, Permission.manageSettings);
    if (mode == CommissionMode.tiered) {
      final problem = validateTiers(tiers);
      if (problem != null) throw ArgumentError.value(tiers, 'tiers', problem);
    }
    final tiersJson = mode == CommissionMode.tiered ? encodeTiers(tiers) : null;
    return _db.transaction(() async {
      final atMs = at.toUtc().millisecondsSinceEpoch;
      final current =
          await (_db.select(_db.commissionRules)
                ..where(
                  (t) =>
                      t.provider.equals(provider) &
                      t.txnType.equals(type.dbName) &
                      t.effectiveFrom.isSmallerOrEqualValue(atMs) &
                      (t.effectiveTo.isNull() |
                          t.effectiveTo.isBiggerThanValue(atMs)),
                )
                ..orderBy([(t) => OrderingTerm.desc(t.effectiveFrom)])
                ..limit(1))
              .getSingleOrNull();

      if (current != null &&
          current.mode == mode.dbName &&
          current.value == value &&
          current.tiersJson == tiersJson) {
        return;
      }
      if (current != null) {
        if (current.effectiveFrom == atMs) {
          // Same instant: replace instead of creating a zero-length rule.
          await (_db.update(
            _db.commissionRules,
          )..where((t) => t.id.equals(current.id))).write(
            CommissionRulesCompanion(
              mode: Value(mode.dbName),
              value: Value(value),
            ),
          );
          return;
        }
        await (_db.update(_db.commissionRules)
              ..where((t) => t.id.equals(current.id)))
            .write(CommissionRulesCompanion(effectiveTo: Value(atMs)));
      }
      final id = _ids.next();
      await _db
          .into(_db.commissionRules)
          .insert(
            CommissionRulesCompanion.insert(
              id: id,
              provider: provider,
              txnType: type.dbName,
              mode: mode.dbName,
              value: value,
              tiersJson: Value(tiersJson),
              effectiveFrom: atMs,
            ),
          );
      await _audit.log(
        userId: userId,
        action: 'rate_change',
        entity: 'commission_rule',
        entityId: id,
        before: current == null
            ? null
            : {
                'mode': current.mode,
                'value': current.value,
                'tiers': ?current.tiersJson,
              },
        after: {
          'provider': provider,
          'txn_type': type.dbName,
          'mode': mode.dbName,
          'value': value,
          'tiers': ?tiersJson,
        },
      );
    });
  }
}
