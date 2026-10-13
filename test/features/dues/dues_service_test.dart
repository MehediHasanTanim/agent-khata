import 'package:agentkhata/core/ledger/account.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/customers/customer_repository.dart';
import 'package:agentkhata/features/dues/dues_service.dart';
import 'package:agentkhata/features/transactions/integrity_checker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

void main() {
  late LedgerFixture f;
  late DuesService dues;

  setUp(() async {
    f = await LedgerFixture.create();
    dues = DuesService(
      db: f.db,
      txns: f.txns,
      customers: CustomerRepository(f.db, f.ids, clock: f.clock),
      ids: f.ids,
      clock: f.clock,
    );
  });
  tearDown(() => f.dispose());

  Future<Money> bal(String id) => f.accounts.balanceOf(id);

  test('credit given: cash leaves, receivable grows, due is open', () async {
    final id = await dues.create(
      direction: DueDirection.theyOwe,
      amount: const Money.taka(500),
      accountId: f.cash,
      name: 'Karim',
      phone: '01711111111',
      note: 'rice',
    );
    expect(await bal(f.cash), const Money.taka(9500));
    expect(await bal(kReceivableAccountId), const Money.taka(500));

    final due = await dues.byId(id);
    expect(due!.remaining, const Money.taka(500));
    expect(due.displayName, 'Karim');
    expect(due.isOpen, isTrue);
  });

  test('flexiload on credit comes from the load balance', () async {
    await dues.create(
      direction: DueDirection.theyOwe,
      amount: const Money.taka(100),
      accountId: f.gpLoad,
      name: 'Salma',
    );
    expect(await bal(f.gpLoad), const Money.taka(4900));
  });

  test('partial then full settlement', () async {
    final id = await dues.create(
      direction: DueDirection.theyOwe,
      amount: const Money.taka(500),
      accountId: f.cash,
      name: 'Karim',
    );
    await dues.settle(
      dueId: id,
      amount: const Money.taka(200),
      accountId: f.cash,
    );
    expect(await bal(f.cash), const Money.taka(9700));
    expect(await bal(kReceivableAccountId), const Money.taka(300));
    expect((await dues.byId(id))!.remaining, const Money.taka(300));
    expect((await dues.watchOpen().first), hasLength(1));

    await dues.settle(
      dueId: id,
      amount: const Money.taka(300),
      accountId: f.bkash,
    );
    expect(await bal(f.bkash), const Money.taka(50300));
    expect(await bal(kReceivableAccountId), Money.zero);
    expect(await dues.watchOpen().first, isEmpty);
    expect((await dues.settlements(id)), hasLength(2));
  });

  test('cannot settle more than is open or a non-positive amount', () async {
    final id = await dues.create(
      direction: DueDirection.theyOwe,
      amount: const Money.taka(100),
      accountId: f.cash,
      name: 'A',
    );
    await expectLater(
      dues.settle(dueId: id, amount: const Money.taka(101), accountId: f.cash),
      throwsA(isA<DueException>().having((e) => e.code, 'code', 'over_settle')),
    );
    await expectLater(
      dues.settle(dueId: id, amount: Money.zero, accountId: f.cash),
      throwsA(isA<DueException>()),
    );
    await expectLater(
      dues.settle(
        dueId: 'missing',
        amount: const Money.taka(1),
        accountId: f.cash,
      ),
      throwsA(isA<DueException>().having((e) => e.code, 'code', 'not_found')),
    );
  });

  test('money held for a customer is a liability, returned later', () async {
    final id = await dues.create(
      direction: DueDirection.iOwe,
      amount: const Money.taka(1000),
      accountId: f.cash,
      phone: '01800000000',
    );
    expect(await bal(f.cash), const Money.taka(11000));
    expect(await bal(kPayableAccountId), const Money.taka(-1000));

    await dues.settle(
      dueId: id,
      amount: const Money.taka(400),
      accountId: f.cash,
    );
    expect(await bal(f.cash), const Money.taka(10600));
    expect(await bal(kPayableAccountId), const Money.taka(-600));

    final totals = await dues.watchTotals().first;
    expect(totals.iOwe, const Money.taka(600));
    expect(totals.theyOwe, Money.zero);
  });

  test(
    'voiding a payment re-opens the due; voiding the due closes it',
    () async {
      final id = await dues.create(
        direction: DueDirection.theyOwe,
        amount: const Money.taka(300),
        accountId: f.cash,
        name: 'Rafi',
      );
      final payment = await dues.settle(
        dueId: id,
        amount: const Money.taka(300),
        accountId: f.cash,
      );
      expect(await dues.watchOpen().first, isEmpty);

      await f.txns.voidTransaction(payment, reason: 'mistake', userId: 'owner');
      expect((await dues.byId(id))!.remaining, const Money.taka(300));
      expect(await dues.watchOpen().first, hasLength(1));

      final created = (await f.db.select(f.db.dues).getSingle()).createdTxnId;
      await f.txns.voidTransaction(created, reason: 'wrong', userId: 'owner');
      expect(await dues.watchOpen().first, isEmpty);
      expect((await dues.byId(id))!.isVoid, isTrue);
    },
  );

  test('search by name or phone and totals', () async {
    await dues.create(
      direction: DueDirection.theyOwe,
      amount: const Money.taka(100),
      accountId: f.cash,
      name: 'Karim',
      phone: '01711111111',
    );
    await dues.create(
      direction: DueDirection.theyOwe,
      amount: const Money.taka(250),
      accountId: f.cash,
      name: 'Salma',
    );
    expect(await dues.watchOpen(query: 'kar').first, hasLength(1));
    expect(await dues.watchOpen(query: '0171').first, hasLength(1));
    expect(await dues.watchOpen(query: '%').first, isEmpty);
    expect((await dues.watchTotals().first).theyOwe, const Money.taka(350));
  });

  test(
    'the same customer is reused; a customer needs a name or phone',
    () async {
      await dues.create(
        direction: DueDirection.theyOwe,
        amount: const Money.taka(10),
        accountId: f.cash,
        name: 'Karim',
      );
      await dues.create(
        direction: DueDirection.theyOwe,
        amount: const Money.taka(20),
        accountId: f.cash,
        name: 'karim',
      );
      expect(await f.db.select(f.db.customers).get(), hasLength(1));
      await expectLater(
        dues.create(
          direction: DueDirection.theyOwe,
          amount: const Money.taka(5),
          accountId: f.cash,
        ),
        throwsArgumentError,
      );
    },
  );

  test('due rows are append-only and the books stay balanced', () async {
    final id = await dues.create(
      direction: DueDirection.theyOwe,
      amount: const Money.taka(50),
      accountId: f.cash,
      name: 'X',
    );
    await expectLater(
      f.db.customStatement('DELETE FROM due WHERE id = ?', [id]),
      throwsA(predicate((e) => e.toString().contains('cannot be deleted'))),
    );
    await expectLater(
      f.db.customStatement('UPDATE due SET amount_paisa = 1 WHERE id = ?', [
        id,
      ]),
      throwsA(predicate((e) => e.toString().contains('immutable'))),
    );
    expect((await LedgerIntegrityChecker(f.db).run()).isHealthy, isTrue);
  });

  test('day close ignores the hidden accounts', () async {
    await dues.create(
      direction: DueDirection.theyOwe,
      amount: const Money.taka(50),
      accountId: f.cash,
      name: 'X',
    );
    final accounts = await f.accounts.watchCounted().first;
    expect(accounts.map((a) => a.id), isNot(contains(kReceivableAccountId)));
  });
}
