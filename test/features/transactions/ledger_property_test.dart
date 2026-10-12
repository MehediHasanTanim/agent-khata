import 'dart:math';

import 'package:agentkhata/core/ledger/account.dart';
import 'package:agentkhata/core/ledger/account_kind.dart';
import 'package:agentkhata/core/ledger/strategies.dart';
import 'package:agentkhata/core/ledger/transaction_draft.dart';
import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/transactions/integrity_checker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

/// Builds a random, mostly-valid draft for [t] using the fixture's accounts.
TransactionDraft _randomDraft(LedgerFixture f, Random r, TransactionType t) {
  final amount = Money.paisa(
    (r.nextInt(500000) + 1) * (r.nextBool() ? 100 : 1),
  );
  final charge = Money.paisa(r.nextInt(3) == 0 ? r.nextInt(5000) : 0);
  final wallets = [f.bkash, f.nagad];
  final wallet = wallets[r.nextInt(2)];
  final at = DateTime.utc(2026, 10, 20, r.nextInt(24), r.nextInt(60));

  TransactionDraft make({
    String? from,
    String? to,
    Money c = Money.zero,
    Money commission = Money.zero,
    String? note,
  }) => TransactionDraft(
    type: t,
    occurredAt: at,
    amount: amount,
    fromAccountId: from,
    toAccountId: to,
    charge: c,
    commission: commission,
    note: note,
  );

  switch (t) {
    case TransactionType.cashIn:
    case TransactionType.sendMoney:
    case TransactionType.billPay:
      return make(from: wallet, to: f.cash, c: charge);
    case TransactionType.cashOut:
      return make(
        from: f.cash,
        to: wallet,
        commission: amount.mulRatio(r.nextInt(900), 100000),
      );
    case TransactionType.flexiload:
      return make(
        from: f.gpLoad,
        to: f.cash,
        commission: amount.mulRatio(r.nextInt(500), 10000),
      );
    case TransactionType.floatPurchase:
      return make(from: r.nextBool() ? f.cash : f.bank, to: wallet);
    case TransactionType.floatTransfer:
      return make(
        from: wallet,
        to: wallet == f.bkash ? f.nagad : f.bkash,
        c: charge,
      );
    case TransactionType.bankDeposit:
      return r.nextBool()
          ? make(from: f.cash, to: f.bank)
          : make(from: f.bank, to: f.cash);
    case TransactionType.expense:
      return make(from: f.cash, to: f.rent);
    case TransactionType.adjustment:
      return r.nextBool()
          ? make(to: f.cash, note: 'excess')
          : make(from: wallet, note: 'shortage');
  }
}

void main() {
  test('strategies: every random valid draft posts balanced entries', () {
    final r = Random(42);
    final accounts = MapAccountResolver([
      const Account(id: 'c', kind: AccountKind.cash, label: 'c'),
      const Account(id: 'w', kind: AccountKind.wallet, label: 'w'),
      const Account(id: 'w2', kind: AccountKind.wallet, label: 'w2'),
      const Account(id: 'l', kind: AccountKind.load, label: 'l'),
      const Account(id: 'b', kind: AccountKind.bank, label: 'b'),
      const Account(id: 'e', kind: AccountKind.expense, label: 'e'),
      const Account(
        id: kExternalAccountId,
        kind: AccountKind.external,
        label: 'x',
      ),
    ]);
    final registry = PostingRegistry.standard();
    var posted = 0;
    for (var i = 0; i < 5000; i++) {
      final t =
          TransactionType.values[r.nextInt(TransactionType.values.length)];
      final amount = Money.paisa(r.nextInt(10000000) + 1);
      final charge = Money.paisa(r.nextInt(2) == 0 ? r.nextInt(10000) : 0);
      final d = switch (t) {
        TransactionType.cashIn ||
        TransactionType.sendMoney ||
        TransactionType.billPay => _d(t, amount, 'w', 'c', charge),
        TransactionType.cashOut => _d(t, amount, 'c', 'w'),
        TransactionType.flexiload => _d(
          t,
          amount,
          'l',
          'c',
          Money.zero,
          amount.mulRatio(r.nextInt(1000), 10000),
        ),
        TransactionType.floatPurchase => _d(t, amount, 'b', 'w'),
        TransactionType.floatTransfer => _d(t, amount, 'w', 'w2', charge),
        TransactionType.bankDeposit => _d(t, amount, 'c', 'b'),
        TransactionType.expense => _d(t, amount, 'c', 'e'),
        TransactionType.adjustment =>
          r.nextBool()
              ? TransactionDraft(
                  type: t,
                  occurredAt: DateTime.utc(2026),
                  amount: amount,
                  toAccountId: 'c',
                  note: 'x',
                )
              : TransactionDraft(
                  type: t,
                  occurredAt: DateTime.utc(2026),
                  amount: amount,
                  fromAccountId: 'c',
                  note: 'x',
                ),
      };
      final entries = registry.strategyFor(t).post(d, accounts);
      expect(entries.fold<int>(0, (s, e) => s + e.deltaPaisa), 0);
      posted++;
    }
    expect(posted, 5000);
  });

  test('database: random sequences keep every invariant', () async {
    for (var seed = 0; seed < 25; seed++) {
      final r = Random(seed);
      final f = await LedgerFixture.create();
      final openingTotal = <String, Money>{};
      final startBalances = await f.accounts.balances();
      openingTotal.addAll(startBalances);

      final live = <String>[];
      for (var i = 0; i < 80; i++) {
        final roll = r.nextInt(10);
        if (roll < 2 && live.isNotEmpty) {
          final id = live.removeAt(r.nextInt(live.length));
          await f.txns.voidTransaction(id, reason: 'random', userId: 'owner');
        } else {
          final t =
              TransactionType.values[r.nextInt(TransactionType.values.length)];
          live.add(await f.txns.post(_randomDraft(f, r, t)));
        }
      }

      final report = await LedgerIntegrityChecker(f.db).run();
      expect(report.isHealthy, isTrue, reason: 'seed $seed');

      // Conservation: value never appears from nowhere. The sum of all
      // balance changes (incl. external and expense) is exactly zero.
      final end = await f.accounts.balances();
      final delta = end.entries.fold<int>(
        0,
        (s, e) => s + e.value.paisa - (openingTotal[e.key]?.paisa ?? 0),
      );
      expect(delta, 0, reason: 'seed $seed');

      // Voiding everything returns every account to its opening balance.
      for (final id in live) {
        await f.txns.voidTransaction(id, reason: 'undo', userId: 'owner');
      }
      expect(await f.accounts.balances(), openingTotal, reason: 'seed $seed');
      await f.dispose();
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}

TransactionDraft _d(
  TransactionType t,
  Money amount,
  String from,
  String to, [
  Money charge = Money.zero,
  Money commission = Money.zero,
]) => TransactionDraft(
  type: t,
  occurredAt: DateTime.utc(2026),
  amount: amount,
  fromAccountId: from,
  toAccountId: to,
  charge: charge,
  commission: commission,
);
