import 'package:agentkhata/features/transactions/history_filter.dart';
import 'package:agentkhata/features/transactions/history_queries.dart';
import 'package:agentkhata/features/transactions/integrity_checker.dart';
import 'package:agentkhata/features/transactions/transaction_queries.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

/// Regression guard for "10,000+ entries stay smooth". Thresholds are loose
/// on purpose (laptop numbers, not a 2 GB phone); they catch accidental
/// full-table scans or O(n^2) behaviour, not small slowdowns.
void main() {
  const rows = 10000;
  late LedgerFixture f;

  setUpAll(() async {
    f = await LedgerFixture.create();
    final base = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch;
    await f.db.transaction(() async {
      await f.db.customStatement('''
WITH RECURSIVE n(i) AS (
  SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < $rows
)
INSERT INTO txn (id, type, occurred_at, recorded_at, amount_paisa,
                 commission_paisa, customer_number, created_by, device_id)
SELECT 't' || printf('%06d', i),
       CASE i % 3 WHEN 0 THEN 'cash_in' ELSE 'cash_out' END,
       $base + i * 60000, $base + i * 60000,
       (i % 50 + 1) * 10000, 400,
       CASE WHEN i % 7 = 0 THEN '0171' || printf('%07d', i) END,
       'owner', 'bench'
FROM n''');
      await f.db.customStatement('''
WITH RECURSIVE n(i) AS (
  SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < $rows
)
INSERT INTO ledger_entry (id, txn_id, account_id, delta_paisa, line_no)
SELECT 'a' || printf('%06d', i), 't' || printf('%06d', i), '${f.cash}',
       CASE i % 3 WHEN 0 THEN 1 ELSE -1 END * (i % 50 + 1) * 10000, 0
FROM n
UNION ALL
SELECT 'b' || printf('%06d', i), 't' || printf('%06d', i), '${f.bkash}',
       CASE i % 3 WHEN 0 THEN -1 ELSE 1 END * (i % 50 + 1) * 10000, 1
FROM n''');
    });
  });

  tearDownAll(() => f.dispose());

  Future<int> time(Future<void> Function() body) async {
    final w = Stopwatch()..start();
    await body();
    return w.elapsedMilliseconds;
  }

  test('history first page and a deep keyset page are fast', () async {
    final q = HistoryQueries(f.db);
    HistoryCursor? cursor;
    final first = await time(() async {
      final p = await q.page(const HistoryFilter(), limit: 50);
      cursor = p.last.cursor;
    });
    final deep = await time(() async {
      for (var i = 0; i < 100; i++) {
        final p = await q.page(const HistoryFilter(), after: cursor, limit: 50);
        cursor = p.last.cursor;
      }
    });
    // ignore: avoid_print
    print('history: first page ${first}ms, 100 deep pages ${deep}ms');
    expect(first, lessThan(500));
    expect(deep, lessThan(10000));
  });

  test('history page uses the occurred_at index', () async {
    final plan = await f.db
        .customSelect(
          'EXPLAIN QUERY PLAN SELECT t.id FROM txn t '
          'ORDER BY t.occurred_at DESC, t.id DESC LIMIT 50',
        )
        .get();
    final text = plan.map((r) => r.data.values.join(' ')).join('\n');
    expect(text, contains('idx_txn_occurred'));
  });

  test('balances, summary, search and ledger stay responsive', () async {
    final balancesMs = await time(() async {
      final b = await f.accounts.balances();
      expect(b[f.cash], isNotNull);
    });
    final summaryMs = await time(() async {
      await TransactionQueries(f.db)
          .watchSummary(DateTime.utc(2026, 1, 1), DateTime.utc(2026, 12, 31))
          .first;
    });
    final searchMs = await time(() async {
      final r = await HistoryQueries(f.db)
          .page(const HistoryFilter(query: '0171'), limit: 50);
      expect(r, isNotEmpty);
    });
    final ledgerMs = await time(() async {
      final l = await AccountLedgerQueries(f.db).page(f.cash, limit: 100);
      expect(l, hasLength(100));
    });
    final integrityMs = await time(() async {
      expect((await LedgerIntegrityChecker(f.db).run()).isHealthy, isTrue);
    });
    // ignore: avoid_print
    print(
      'balances ${balancesMs}ms, summary ${summaryMs}ms, search ${searchMs}ms, '
      'ledger ${ledgerMs}ms, integrity ${integrityMs}ms',
    );
    expect(balancesMs, lessThan(1500));
    expect(summaryMs, lessThan(1500));
    expect(searchMs, lessThan(1500));
    expect(ledgerMs, lessThan(3000));
    expect(integrityMs, lessThan(8000));
  });
}
