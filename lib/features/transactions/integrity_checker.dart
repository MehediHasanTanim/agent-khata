import '../../core/db/app_database.dart';
import '../../core/money/money.dart';

class BalanceMismatch {
  const BalanceMismatch(this.accountId, this.reported, this.recomputed);

  final String accountId;
  final Money reported;
  final Money recomputed;
}

class IntegrityReport {
  const IntegrityReport({
    required this.unbalancedTxnIds,
    required this.balanceMismatches,
    required this.orphanEntryCount,
  });

  /// Active transactions whose entries do not sum to zero.
  final List<String> unbalancedTxnIds;

  /// Accounts where the SQL balance and a from-scratch recompute differ.
  final List<BalanceMismatch> balanceMismatches;

  /// Ledger entries pointing at a missing transaction or account.
  final int orphanEntryCount;

  bool get isHealthy =>
      unbalancedTxnIds.isEmpty &&
      balanceMismatches.isEmpty &&
      orphanEntryCount == 0;
}

/// Recomputes balances in Dart from raw rows and compares them with the SQL
/// balance query, and checks every active transaction balances to zero.
/// Backs the "books verified" indicator.
class LedgerIntegrityChecker {
  LedgerIntegrityChecker(this._db);

  final AppDatabase _db;

  Future<IntegrityReport> run() async {
    final accounts = await _db.select(_db.accounts).get();
    final txns = await _db.select(_db.txns).get();
    final entries = await _db.select(_db.ledgerEntries).get();

    final activeTxnIds = {
      for (final t in txns)
        if (t.status == 'active') t.id,
    };
    final accountIds = {for (final a in accounts) a.id};
    final txnIds = {for (final t in txns) t.id};

    final perTxn = <String, int>{};
    final perAccount = <String, int>{};
    var orphans = 0;
    for (final e in entries) {
      if (!txnIds.contains(e.txnId) || !accountIds.contains(e.accountId)) {
        orphans++;
        continue;
      }
      if (!activeTxnIds.contains(e.txnId)) continue;
      perTxn[e.txnId] = (perTxn[e.txnId] ?? 0) + e.deltaPaisa;
      perAccount[e.accountId] = (perAccount[e.accountId] ?? 0) + e.deltaPaisa;
    }

    final unbalanced = [
      for (final t in activeTxnIds)
        if ((perTxn[t] ?? 0) != 0) t,
    ];

    final sqlBalances = <String, int>{
      for (final r in await _db.customSelect('''
SELECT a.id AS account_id,
       a.opening_paisa + COALESCE((
         SELECT SUM(le.delta_paisa) FROM ledger_entry le
         JOIN txn t ON t.id = le.txn_id
         WHERE le.account_id = a.id AND t.status = 'active'), 0) AS balance
FROM account a''').get())
        r.read<String>('account_id'): r.read<int>('balance'),
    };

    final mismatches = <BalanceMismatch>[];
    for (final a in accounts) {
      final recomputed = a.openingPaisa + (perAccount[a.id] ?? 0);
      final reported = sqlBalances[a.id] ?? 0;
      if (recomputed != reported) {
        mismatches.add(
          BalanceMismatch(a.id, Money.paisa(reported), Money.paisa(recomputed)),
        );
      }
    }

    return IntegrityReport(
      unbalancedTxnIds: unbalanced,
      balanceMismatches: mismatches,
      orphanEntryCount: orphans,
    );
  }
}
