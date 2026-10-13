import 'package:agentkhata/core/ledger/transaction_draft.dart';
import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/entry/bulk_flexiload.dart';
import 'package:agentkhata/features/transactions/bulk_flexiload_service.dart';
import 'package:agentkhata/features/transactions/history_filter.dart';
import 'package:agentkhata/features/transactions/history_queries.dart';
import 'package:agentkhata/features/transactions/transaction_queries.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

void main() {
  late LedgerFixture f;
  late BulkFlexiloadService bulk;

  setUp(() async {
    f = await LedgerFixture.create();
    bulk = BulkFlexiloadService(f.db, f.txns);
  });
  tearDown(() => f.dispose());

  Money margin(Money price) => price.mulRatio(300, 10000); // 3%

  group('bulk flexiload', () {
    test('posts one entry per row with margin and number', () async {
      final ids = await bulk.save(
        operatorAccountId: f.gpLoad,
        cashAccountId: f.cash,
        rows: const [
          BulkRow(number: '01712345678', amount: Money.taka(100)),
          BulkRow(number: '+8801811111111', amount: Money.taka(50)),
          BulkRow(), // blank rows are skipped
          BulkRow(amount: Money.taka(20)),
        ],
        marginFor: margin,
        createdBy: 'owner',
      );
      expect(ids, hasLength(3));

      // Price 170 in cash; load falls by cost = 170 - 3% = 164.90.
      expect(await f.accounts.balanceOf(f.cash), const Money.taka(10170));
      expect(
        (await f.accounts.balanceOf(f.gpLoad)).paisa,
        500000 - (17000 - 510),
      );

      final items = await HistoryQueries(f.db).page(const HistoryFilter());
      expect(items.map((i) => i.customerNumber), contains('01811111111'));
      expect(items.every((i) => i.type == TransactionType.flexiload), isTrue);
    });

    test('is all-or-nothing', () async {
      await expectLater(
        bulk.save(
          operatorAccountId: f.gpLoad,
          cashAccountId: f.cash,
          rows: const [
            BulkRow(number: '01712345678', amount: Money.taka(100)),
            BulkRow(number: '01811111111'), // number without an amount
          ],
          marginFor: margin,
          createdBy: 'owner',
        ),
        throwsArgumentError,
      );
      expect(await f.db.select(f.db.txns).get(), isEmpty);
    });

    test('a failing row rolls back the earlier rows', () async {
      // The margin for the 200 row exceeds its price, which the posting rules
      // reject, after the 100 row was already written.
      await expectLater(
        bulk.save(
          operatorAccountId: f.gpLoad,
          cashAccountId: f.cash,
          rows: const [
            BulkRow(amount: Money.taka(100)),
            BulkRow(amount: Money.taka(200)),
          ],
          marginFor: (p) =>
              p.wholeTaka == 200 ? const Money.taka(999) : margin(p),
          createdBy: 'owner',
        ),
        throwsA(isA<Exception>()),
      );
      expect(await f.db.select(f.db.txns).get(), isEmpty);
      expect(await f.accounts.balanceOf(f.cash), const Money.taka(10000));
    });

    test('undo voids the whole batch', () async {
      final ids = await bulk.save(
        operatorAccountId: f.gpLoad,
        cashAccountId: f.cash,
        rows: const [
          BulkRow(amount: Money.taka(100)),
          BulkRow(amount: Money.taka(200)),
        ],
        marginFor: margin,
        createdBy: 'owner',
      );
      await bulk.voidAll(ids, userId: 'owner');
      expect(await f.accounts.balanceOf(f.cash), const Money.taka(10000));
      expect(await f.accounts.balanceOf(f.gpLoad), const Money.taka(5000));
    });

    test('nothing to save is a no-op', () async {
      expect(
        await bulk.save(
          operatorAccountId: f.gpLoad,
          cashAccountId: f.cash,
          rows: const [BulkRow()],
          marginFor: margin,
          createdBy: 'owner',
        ),
        isEmpty,
      );
    });
  });

  group('regular customers', () {
    TransactionDraft draft(
      TransactionType type,
      String number,
      int taka, {
      required DateTime at,
      String? wallet,
      String by = 'owner',
    }) => TransactionDraft(
      type: type,
      occurredAt: at,
      amount: Money.taka(taka),
      fromAccountId: type == TransactionType.cashOut
          ? f.cash
          : (wallet ?? f.gpLoad),
      toAccountId: type == TransactionType.cashOut
          ? (wallet ?? f.bkash)
          : f.cash,
      customerNumber: number,
      createdBy: by,
    );

    DateTime at(int day) => DateTime.utc(2026, 10, day, 10);

    test('lists numbers served at least twice, most often first', () async {
      final q = TransactionQueries(f.db);
      // 0171: flexiload x3 (last 100), 0181: cash out x2 (last 2000),
      // 0191: once only.
      for (var i = 1; i <= 3; i++) {
        await f.txns.post(
          draft(TransactionType.flexiload, '01712345678', 50 * i, at: at(i)),
        );
      }
      await f.txns.post(
        draft(TransactionType.cashOut, '01811111111', 500, at: at(4)),
      );
      await f.txns.post(
        draft(
          TransactionType.cashOut,
          '01811111111',
          2000,
          at: at(5),
          wallet: f.nagad,
        ),
      );
      await f.txns.post(
        draft(TransactionType.flexiload, '01911222333', 20, at: at(6)),
      );

      final r = await q.regulars();
      expect(r.map((c) => c.number), ['01712345678', '01811111111']);
      expect(r.first.uses, 3);
      expect(r.first.lastAmount, const Money.taka(150));
      expect(r.first.accountId, f.gpLoad);
      expect(r.last.lastAmount, const Money.taka(2000));
      expect(r.last.accountId, f.nagad);
    });

    test('filters by type and ignores voided entries', () async {
      final q = TransactionQueries(f.db);
      await f.txns.post(
        draft(TransactionType.flexiload, '01712345678', 50, at: at(1)),
      );
      final second = await f.txns.post(
        draft(TransactionType.flexiload, '01712345678', 60, at: at(2)),
      );
      expect(await q.regulars(type: TransactionType.flexiload), hasLength(1));
      expect(await q.regulars(type: TransactionType.cashOut), isEmpty);

      await f.txns.voidTransaction(second, reason: 'x', userId: 'owner');
      expect(await q.regulars(), isEmpty); // only one active use left
    });

    test('staff see only the numbers they served', () async {
      final q = TransactionQueries(f.db);
      await f.txns.post(
        draft(TransactionType.flexiload, '01712345678', 50, at: at(1)),
      );
      await f.txns.post(
        draft(
          TransactionType.flexiload,
          '01712345678',
          60,
          at: at(2),
          by: 's1',
        ),
      );
      await f.txns.post(
        draft(
          TransactionType.flexiload,
          '01712345678',
          70,
          at: at(3),
          by: 's1',
        ),
      );
      expect((await q.regulars()).single.uses, 3);
      final own = await q.regulars(createdBy: 's1');
      expect(own.single.uses, 2);
      expect(own.single.lastAmount, const Money.taka(70));
      expect(await q.regulars(createdBy: 'nobody'), isEmpty);
    });

    test('respects minUses and the limit', () async {
      final q = TransactionQueries(f.db);
      for (var n = 0; n < 5; n++) {
        await f.txns.post(
          draft(TransactionType.flexiload, '0171000000$n', 10, at: at(1)),
        );
      }
      expect(await q.regulars(), isEmpty);
      expect(await q.regulars(minUses: 1, limit: 3), hasLength(3));
    });
  });
}
