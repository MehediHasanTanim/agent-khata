import 'package:agentkhata/core/db/app_database.dart';
import 'package:agentkhata/core/db/db_settings.dart';
import 'package:agentkhata/core/ledger/account_kind.dart';
import 'package:agentkhata/core/ledger/posting_strategy.dart';
import 'package:agentkhata/core/ledger/transaction_draft.dart';
import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/transactions/integrity_checker.dart';
import 'package:agentkhata/features/transactions/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

void main() {
  late LedgerFixture f;

  setUp(() async => f = await LedgerFixture.create());
  tearDown(() => f.dispose());

  Future<Money> balance(String id) => f.accounts.balanceOf(id);

  test('opening balances show before any transaction', () async {
    expect(await balance(f.cash), const Money.taka(10000));
    expect(await balance(f.bkash), const Money.taka(50000));
  });

  test('cash-out moves cash down and float up', () async {
    await f.txns.post(f.cashOutDraft(2000));
    expect(await balance(f.cash), const Money.taka(8000));
    expect(await balance(f.bkash), const Money.taka(52000));
  });

  test('cash-in moves cash up and float down', () async {
    await f.txns.post(f.cashInDraft(1000));
    expect(await balance(f.cash), const Money.taka(11000));
    expect(await balance(f.bkash), const Money.taka(49000));
  });

  test('stores commission snapshot, entries and an audit row', () async {
    final id = await f.txns.post(f.cashOutDraft(2000));
    final row = await (f.db.select(
      f.db.txns,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(row.commissionPaisa, 8000);
    expect(row.deviceId, 'test-device');
    expect(row.status, 'active');

    final entries = await (f.db.select(
      f.db.ledgerEntries,
    )..where((t) => t.txnId.equals(id))).get();
    expect(entries.map((e) => e.deltaPaisa).fold<int>(0, (a, b) => a + b), 0);
    expect(entries, hasLength(2));

    final audit = await f.db.select(f.db.auditLogs).get();
    expect(audit.single.action, 'txn_create');
    expect(audit.single.entityId, id);
  });

  test('invalid drafts write nothing', () async {
    await expectLater(
      f.txns.post(
        TransactionDraft(
          type: TransactionType.cashOut,
          occurredAt: DateTime.utc(2026, 10, 20),
          amount: Money.zero,
          fromAccountId: f.cash,
          toAccountId: f.bkash,
        ),
      ),
      throwsA(isA<PostingException>()),
    );
    expect(await f.db.select(f.db.txns).get(), isEmpty);
    expect(await f.db.select(f.db.auditLogs).get(), isEmpty);
  });

  test('a rejected draft leaves no partial rows', () async {
    final bad = TransactionDraft(
      type: TransactionType.cashOut,
      occurredAt: DateTime.utc(2026, 10, 20),
      amount: const Money.taka(10),
      fromAccountId: f.cash,
      toAccountId: f.rent, // expense account => rejected by validation
    );
    await expectLater(f.txns.post(bad), throwsA(isA<PostingException>()));
    expect(await f.db.select(f.db.txns).get(), isEmpty);
  });

  group('void', () {
    test('restores balances and keeps the rows', () async {
      final id = await f.txns.post(f.cashOutDraft(2000));
      await f.txns.voidTransaction(id, reason: 'typo', userId: 'owner');
      expect(await balance(f.cash), const Money.taka(10000));
      expect(await balance(f.bkash), const Money.taka(50000));

      expect(await f.db.select(f.db.txns).get(), hasLength(1));
      expect(await f.db.select(f.db.ledgerEntries).get(), hasLength(2));
      final audit = await f.db.select(f.db.auditLogs).get();
      expect(audit.map((a) => a.action), ['txn_create', 'txn_void']);
      expect(audit.last.reason, 'typo');
    });

    test('requires a reason and cannot be repeated', () async {
      final id = await f.txns.post(f.cashOutDraft(100));
      expect(
        () => f.txns.voidTransaction(id, reason: ' ', userId: 'owner'),
        throwsArgumentError,
      );
      await f.txns.voidTransaction(id, reason: 'x', userId: 'owner');
      await expectLater(
        f.txns.voidTransaction(id, reason: 'x', userId: 'owner'),
        throwsStateError,
      );
    });

    test('void then re-add returns to the same balance', () async {
      final id = await f.txns.post(f.cashOutDraft(750));
      final after = await balance(f.cash);
      await f.txns.voidTransaction(id, reason: 'redo', userId: 'owner');
      await f.txns.post(f.cashOutDraft(750));
      expect(await balance(f.cash), after);
    });
  });

  group('closed days', () {
    test('posting into a closed business day is refused', () async {
      await f.db
          .into(f.db.dayCloses)
          .insert(
            DayClosesCompanion.insert(
              id: 'dc',
              businessDate: '2026-10-20',
              status: 'closed',
            ),
          );
      await expectLater(
        f.txns.post(f.cashOutDraft(10, at: DateTime.utc(2026, 10, 20, 8))),
        throwsA(isA<DayLockedException>()),
      );
      // The next business day is open.
      await f.txns.post(f.cashOutDraft(10, at: DateTime.utc(2026, 10, 21, 8)));
    });

    test('rollover hour decides which day a night sale belongs to', () async {
      await DbSettings(f.db).set(DbSettings.dayRolloverHourKey, '4');
      await f.db
          .into(f.db.dayCloses)
          .insert(
            DayClosesCompanion.insert(
              id: 'dc',
              businessDate: '2026-10-20',
              status: 'closed',
            ),
          );
      // 01:30 Dhaka on the 21st = 19:30 UTC on the 20th => still the 20th.
      await expectLater(
        f.txns.post(f.cashOutDraft(10, at: DateTime.utc(2026, 10, 20, 19, 30))),
        throwsA(isA<DayLockedException>()),
      );
    });

    test('voiding a transaction of a closed day is refused', () async {
      final id = await f.txns.post(f.cashOutDraft(10));
      await f.db
          .into(f.db.dayCloses)
          .insert(
            DayClosesCompanion.insert(
              id: 'dc',
              businessDate: '2026-10-20',
              status: 'closed',
            ),
          );
      await f.db.customStatement(
        "UPDATE txn SET day_close_id = 'dc' WHERE id = ?",
        [id],
      );
      await expectLater(
        f.txns.voidTransaction(id, reason: 'x', userId: 'owner'),
        throwsA(isA<DayLockedException>()),
      );
    });
  });

  group('accounts', () {
    test('balance stream emits on every change', () async {
      final stream = f.accounts.watchBalances().map((m) => m[f.cash]);
      final expected = expectLater(
        stream,
        emitsInOrder([
          const Money.taka(10000),
          const Money.taka(8000),
          const Money.taka(10000),
        ]),
      );
      await Future<void>.delayed(Duration.zero);
      final id = await f.txns.post(f.cashOutDraft(2000));
      await Future<void>.delayed(Duration.zero);
      await f.txns.voidTransaction(id, reason: 'x', userId: 'owner');
      await expected;
    });

    test('watchCounted hides system and expense accounts', () async {
      final list = await f.accounts.watchCounted().first;
      expect(list.map((a) => a.kind), isNot(contains(AccountKind.external)));
      expect(list.map((a) => a.kind), isNot(contains(AccountKind.expense)));
      expect(list, hasLength(5));
    });

    test('deactivated accounts are rejected for new postings', () async {
      await f.accounts.setActive(f.nagad, active: false);
      await expectLater(
        f.txns.post(f.cashOutDraft(10, wallet: f.nagad)),
        throwsA(
          isA<PostingException>().having((e) => e.code, 'code', 'inactive_to'),
        ),
      );
    });

    test('external account cannot be created by users', () async {
      await expectLater(
        f.accounts.create(kind: AccountKind.external, label: 'x'),
        throwsArgumentError,
      );
    });
  });

  group('integrity checker', () {
    test('healthy ledger', () async {
      await f.txns.post(f.cashOutDraft(2000));
      await f.txns.post(f.cashInDraft(500));
      final report = await LedgerIntegrityChecker(f.db).run();
      expect(report.isHealthy, isTrue);
    });

    test('detects an unbalanced transaction', () async {
      final id = await f.txns.post(f.cashOutDraft(2000));
      // Bypass the app layer to corrupt the books: add a stray entry.
      await f.db.customStatement(
        'INSERT INTO ledger_entry (id, txn_id, account_id, delta_paisa, '
        "line_no) VALUES ('stray', ?, ?, 500, 9)",
        [id, f.cash],
      );
      final report = await LedgerIntegrityChecker(f.db).run();
      expect(report.isHealthy, isFalse);
      expect(report.unbalancedTxnIds, [id]);
    });
  });
}
