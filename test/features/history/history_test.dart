import 'package:agentkhata/core/ledger/account_kind.dart';
import 'package:agentkhata/core/ledger/posting_strategy.dart';
import 'package:agentkhata/core/ledger/transaction_draft.dart';
import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/customers/customer_repository.dart';
import 'package:agentkhata/features/transactions/history_filter.dart';
import 'package:agentkhata/features/transactions/history_queries.dart';
import 'package:agentkhata/features/transactions/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

void main() {
  late LedgerFixture f;
  late HistoryQueries history;

  setUp(() async {
    f = await LedgerFixture.create();
    history = HistoryQueries(f.db);
  });
  tearDown(() => f.dispose());

  DateTime at(int day, [int hour = 10]) => DateTime.utc(2026, 10, day, hour);

  group('history paging and filters', () {
    test('keyset pagination walks newest to oldest without gaps', () async {
      final ids = <String>[];
      for (var i = 1; i <= 7; i++) {
        ids.add(await f.txns.post(f.cashOutDraft(i * 100, at: at(10 + i))));
      }
      final seen = <String>[];
      HistoryCursor? cursor;
      while (true) {
        final page = await history.page(
          const HistoryFilter(),
          after: cursor,
          limit: 3,
        );
        if (page.isEmpty) break;
        seen.addAll(page.map((p) => p.id));
        cursor = page.last.cursor;
      }
      expect(seen, ids.reversed.toList());
    });

    test('same-timestamp rows are paged stably by id', () async {
      for (var i = 0; i < 5; i++) {
        await f.txns.post(f.cashOutDraft(100 + i, at: at(12)));
      }
      final all = await history.page(const HistoryFilter(), limit: 100);
      final paged = <String>[];
      HistoryCursor? c;
      do {
        final p = await history.page(const HistoryFilter(), after: c, limit: 2);
        if (p.isEmpty) break;
        paged.addAll(p.map((e) => e.id));
        c = p.last.cursor;
      } while (true);
      expect(paged, all.map((e) => e.id).toList());
    });

    test('date range, type and account filters', () async {
      await f.txns.post(f.cashOutDraft(100, at: at(10)));
      await f.txns.post(f.cashInDraft(200, at: at(11)));
      await f.txns.post(f.cashOutDraft(300, wallet: f.nagad, at: at(12)));

      Future<List<int>> amounts(HistoryFilter fl) async => [
        for (final i in await history.page(fl)) i.amount.wholeTaka,
      ];

      expect(await amounts(HistoryFilter(from: at(11), to: at(12))), [200]);
      expect(
        await amounts(const HistoryFilter(types: {TransactionType.cashOut})),
        [300, 100],
      );
      expect(await amounts(HistoryFilter(accountId: f.nagad)), [300]);
    });

    test('voids are listed but can be excluded', () async {
      final id = await f.txns.post(f.cashOutDraft(100, at: at(10)));
      await f.txns.voidTransaction(id, reason: 'x', userId: 'owner');
      final all = await history.page(const HistoryFilter());
      expect(all.single.isVoid, isTrue);
      expect(all.single.voidReason, 'x');
      expect(
        await history.page(const HistoryFilter(includeVoid: false)),
        isEmpty,
      );
    });
  });

  group('search', () {
    setUp(() async {
      await f.txns.post(
        TransactionDraft(
          type: TransactionType.cashOut,
          occurredAt: at(10),
          amount: const Money.taka(2500),
          fromAccountId: f.cash,
          toAccountId: f.bkash,
          customerNumber: '01712345678',
          reference: 'TRX9A8B7C',
          note: 'for rent',
        ),
      );
      await f.txns.post(f.cashOutDraft(1000, at: at(11)));
    });

    Future<int> count(String q) async =>
        (await history.page(HistoryFilter(query: q))).length;

    test('by amount, number, reference and note', () async {
      expect(await count('2500'), 1);
      expect(await count('0171234'), 1);
      expect(await count('9a8b'), 1);
      expect(await count('rent'), 1);
      expect(await count('nothing'), 0);
    });

    test('Bangla digits are normalized', () async {
      expect(await count('২৫০০'), 1);
    });

    test('LIKE wildcards in the query are literal', () async {
      expect(await count('%'), 0);
      expect(await count('_'), 0);
    });

    test('by customer name via the customer table', () async {
      final customers = CustomerRepository(f.db, f.ids, clock: f.clock);
      final cid = await customers.upsert(phone: '01811111111', name: 'Karim');
      await f.txns.post(
        TransactionDraft(
          type: TransactionType.cashIn,
          occurredAt: at(12),
          amount: const Money.taka(300),
          fromAccountId: f.bkash,
          toAccountId: f.cash,
          customerId: cid,
          customerNumber: '01811111111',
        ),
      );
      expect(await count('karim'), 1);
    });

    test('totals ignore voids and respect filters', () async {
      final id = await f.txns.post(f.cashOutDraft(700, at: at(13)));
      await f.txns.voidTransaction(id, reason: 'x', userId: 'owner');
      final t = await history.totals(const HistoryFilter());
      expect(t.count, 2);
      expect(t.amount, const Money.taka(3500));
    });
  });

  group('account ledger', () {
    test('running balance, voids and date filter', () async {
      final ledger = AccountLedgerQueries(f.db);
      await f.txns.post(f.cashOutDraft(2000, at: at(10))); // cash 10000 -> 8000
      final gone = await f.txns.post(f.cashOutDraft(500, at: at(11)));
      await f.txns.voidTransaction(gone, reason: 'x', userId: 'owner');
      await f.txns.post(f.cashInDraft(300, at: at(12))); // -> 8300

      final lines = await ledger.page(f.cash);
      expect(lines.map((l) => l.delta.wholeTaka), [300, -500, -2000]);
      expect(lines.map((l) => l.balance.wholeTaka), [8300, 8000, 8000]);
      expect(lines[1].isVoid, isTrue);

      // The filter hides older lines but balances stay true.
      final filtered = await ledger.page(f.cash, from: at(12));
      expect(filtered, hasLength(1));
      expect(filtered.single.balance.wholeTaka, 8300);

      expect(await f.accounts.balanceOf(f.cash), const Money.taka(8300));
    });
  });

  group('edit', () {
    test('replaces the original atomically and links them', () async {
      final original = await f.txns.post(f.cashOutDraft(2000, at: at(10)));
      final replacement = await f.txns.edit(
        original,
        f.cashOutDraft(2500, at: at(10)),
        userId: 'owner',
      );

      expect(await f.accounts.balanceOf(f.cash), const Money.taka(7500));
      final items = await history.page(const HistoryFilter());
      final old = items.firstWhere((i) => i.id == original);
      final neu = items.firstWhere((i) => i.id == replacement);
      expect(old.isVoid, isTrue);
      expect(neu.isVoid, isFalse);
      expect(neu.replacesTxnId, original);

      final loader = TransactionDetailLoader(f.db, history);
      final detail = await loader.load(original);
      expect(detail!.replacedByTxnId, replacement);
      expect(detail.audit.map((a) => a.action), ['txn_create', 'txn_edit']);
    });

    test('an invalid replacement leaves the original untouched', () async {
      final original = await f.txns.post(f.cashOutDraft(2000, at: at(10)));
      await expectLater(
        f.txns.edit(
          original,
          TransactionDraft(
            type: TransactionType.cashOut,
            occurredAt: at(10),
            amount: Money.zero,
            fromAccountId: f.cash,
            toAccountId: f.bkash,
          ),
          userId: 'owner',
        ),
        throwsA(isA<PostingException>()),
      );
      expect(await f.accounts.balanceOf(f.cash), const Money.taka(8000));
      final item = await history.byId(original);
      expect(item!.isVoid, isFalse);
    });

    test('closed day blocks editing', () async {
      final original = await f.txns.post(f.cashOutDraft(2000, at: at(10)));
      await f.db.customStatement(
        "INSERT INTO day_close (id, business_date, status) VALUES ('dc', '2026-10-10', 'closed')",
      );
      await f.db.customStatement(
        "UPDATE txn SET day_close_id = 'dc' WHERE id = ?",
        [original],
      );
      await expectLater(
        f.txns.edit(original, f.cashOutDraft(100, at: at(11)), userId: 'owner'),
        throwsA(isA<DayLockedException>()),
      );
      expect(await f.accounts.balanceOf(f.cash), const Money.taka(8000));
    });
  });

  group('detail', () {
    test('legs, entries, commission snapshot and audit', () async {
      final id = await f.txns.post(f.cashOutDraft(1000, at: at(10)));
      final d = await TransactionDetailLoader(f.db, history).load(id);
      expect(d!.legs.fromAccountId, f.cash);
      expect(d.legs.toAccountId, f.bkash);
      expect(d.entries, hasLength(2));
      expect(d.item.commission.paisa, 4000);
      expect(d.createdBy, 'owner');
      expect(d.audit.single.action, 'txn_create');
      expect(await TransactionDetailLoader(f.db, history).load('nope'), isNull);
    });
  });

  group('float purchase with charge or discount', () {
    TransactionDraft purchase({int charge = 0, int discount = 0}) =>
        TransactionDraft(
          type: TransactionType.floatPurchase,
          occurredAt: at(10),
          amount: const Money.taka(1000),
          fromAccountId: f.cash,
          toAccountId: f.gpLoad,
          charge: Money.taka(charge),
          discount: Money.taka(discount),
        );

    test('discount: pay less than the stock received', () async {
      await f.txns.post(purchase(discount: 30));
      expect(await f.accounts.balanceOf(f.cash), const Money.taka(9030));
      expect(await f.accounts.balanceOf(f.gpLoad), const Money.taka(6000));
    });

    test('charge: pay more than the stock received', () async {
      await f.txns.post(purchase(charge: 5));
      expect(await f.accounts.balanceOf(f.cash), const Money.taka(8995));
      expect(await f.accounts.balanceOf(f.gpLoad), const Money.taka(6000));
    });

    test('both together, or a discount elsewhere, are rejected', () async {
      await expectLater(
        f.txns.post(purchase(charge: 5, discount: 5)),
        throwsA(isA<PostingException>()),
      );
      await expectLater(
        f.txns.post(
          TransactionDraft(
            type: TransactionType.cashOut,
            occurredAt: at(10),
            amount: const Money.taka(100),
            fromAccountId: f.cash,
            toAccountId: f.bkash,
            discount: const Money.taka(1),
          ),
        ),
        throwsA(isA<PostingException>()),
      );
    });
  });

  group('flexiload end to end', () {
    test('load balance falls by cost, cash rises by price', () async {
      await f.txns.post(
        TransactionDraft(
          type: TransactionType.flexiload,
          occurredAt: at(10),
          amount: const Money.taka(100),
          fromAccountId: f.gpLoad,
          toAccountId: f.cash,
          commission: const Money.taka(3),
        ),
      );
      expect(await f.accounts.balanceOf(f.cash), const Money.taka(10100));
      expect(await f.accounts.balanceOf(f.gpLoad), const Money.taka(4903));
    });
  });

  group('customers', () {
    test('upsert is by phone and suggestions match phone or name', () async {
      final repo = CustomerRepository(f.db, f.ids, clock: f.clock);
      final a = await repo.upsert(phone: '01711111111');
      final again = await repo.upsert(phone: '01711111111', name: 'Rahim');
      expect(again, a);
      await repo.upsert(phone: '01899999999', name: 'Salma');

      final byPhone = await repo.suggest('0171');
      expect(byPhone.single.name, 'Rahim');
      final byName = await repo.suggest('salm');
      expect(byName.single.phone, '01899999999');
      expect(await repo.suggest(''), isEmpty);
      expect(await repo.suggest('%'), isEmpty);
    });
  });

  test('low alert can be set and cleared', () async {
    await f.accounts.setLowAlert(f.bkash, const Money.taka(10000));
    var a = await f.accounts.byId(f.bkash);
    expect(a!.lowAlert, const Money.taka(10000));
    await f.accounts.setLowAlert(f.bkash, null);
    a = await f.accounts.byId(f.bkash);
    expect(a!.lowAlert, isNull);
  });

  test('expense category listing by kind', () async {
    final list = await f.accounts.watchByKind(AccountKind.expense).first;
    expect(list.map((a) => a.label), ['Rent']);
  });
}
