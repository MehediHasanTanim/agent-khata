import 'package:agentkhata/core/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

void main() {
  late LedgerFixture f;
  late String txnId;

  setUp(() async {
    f = await LedgerFixture.create();
    txnId = await f.txns.post(f.cashOutDraft(2000));
  });
  tearDown(() => f.dispose());

  Future<void> expectAborts(Future<void> Function() action, String message) =>
      expectLater(
        action(),
        throwsA(
          predicate((e) => e.toString().contains(message), 'contains $message'),
        ),
      );

  test('txn rows cannot be deleted', () async {
    await expectAborts(
      () => f.db.customStatement('DELETE FROM txn WHERE id = ?', [txnId]),
      'cannot be deleted',
    );
  });

  test('ledger entries cannot be deleted or updated', () async {
    await expectAborts(
      () => f.db.customStatement('DELETE FROM ledger_entry'),
      'cannot be deleted',
    );
    await expectAborts(
      () => f.db.customStatement('UPDATE ledger_entry SET delta_paisa = 1'),
      'immutable',
    );
  });

  test('audit log is append-only', () async {
    await expectAborts(
      () => f.db.customStatement('DELETE FROM audit_log'),
      'cannot be deleted',
    );
    await expectAborts(
      () => f.db.customStatement("UPDATE audit_log SET action = 'x'"),
      'immutable',
    );
  });

  test('txn amount and other core columns are immutable', () async {
    await expectAborts(
      () => f.db.customStatement(
        'UPDATE txn SET amount_paisa = 1 WHERE id = ?',
        [txnId],
      ),
      'immutable',
    );
    await expectAborts(
      () => f.db.customStatement(
        "UPDATE txn SET note = 'changed' WHERE id = ?",
        [txnId],
      ),
      'immutable',
    );
  });

  test('amount must be positive (CHECK)', () async {
    await expectLater(
      f.db.customStatement(
        'INSERT INTO txn (id, type, occurred_at, recorded_at, amount_paisa, '
        "created_by, device_id) VALUES ('z', 'cash_out', 0, 0, 0, 'o', 'd')",
      ),
      throwsA(isA<Exception>()),
    );
  });

  group('closed days', () {
    Future<String> closeDay() async {
      await f.db
          .into(f.db.dayCloses)
          .insert(
            DayClosesCompanion.insert(
              id: 'dc1',
              businessDate: '2026-10-20',
              status: 'closed',
            ),
          );
      await f.db.customStatement(
        "UPDATE txn SET day_close_id = 'dc1' WHERE id = ?",
        [txnId],
      );
      return 'dc1';
    }

    test('locked txn cannot be voided at the DB level', () async {
      await closeDay();
      await expectAborts(
        () => f.db.customStatement(
          "UPDATE txn SET status = 'void' WHERE id = ?",
          [txnId],
        ),
        'closed day',
      );
    });

    test('locked txn cannot gain entries', () async {
      await closeDay();
      await expectAborts(
        () => f.db.customStatement(
          'INSERT INTO ledger_entry (id, txn_id, account_id, delta_paisa, '
          "line_no) VALUES ('le-x', ?, ?, 0, 9)",
          [txnId, f.cash],
        ),
        'closed day',
      );
    });

    test('reopened day allows voiding again', () async {
      await closeDay();
      await f.db.customStatement(
        "UPDATE day_close SET status = 'reopened' WHERE id = 'dc1'",
      );
      await f.db.customStatement(
        "UPDATE txn SET status = 'void' WHERE id = ?",
        [txnId],
      );
      final row = await (f.db.select(
        f.db.txns,
      )..where((t) => t.id.equals(txnId))).getSingle();
      expect(row.status, 'void');
    });
  });
}
