import 'package:agentkhata/core/ledger/account.dart';
import 'package:agentkhata/core/ledger/account_kind.dart';
import 'package:agentkhata/core/ledger/ledger_entry_draft.dart';
import 'package:agentkhata/core/ledger/posting_strategy.dart';
import 'package:agentkhata/core/ledger/strategies.dart';
import 'package:agentkhata/core/ledger/transaction_draft.dart';
import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:flutter_test/flutter_test.dart';

final _accounts = MapAccountResolver([
  const Account(id: 'cash', kind: AccountKind.cash, label: 'Cash'),
  const Account(id: 'bk', kind: AccountKind.wallet, label: 'bKash'),
  const Account(id: 'ng', kind: AccountKind.wallet, label: 'Nagad'),
  const Account(id: 'gp', kind: AccountKind.load, label: 'GP'),
  const Account(id: 'bank', kind: AccountKind.bank, label: 'Bank'),
  const Account(id: 'rent', kind: AccountKind.expense, label: 'Rent'),
  const Account(
    id: 'old',
    kind: AccountKind.wallet,
    label: 'Old',
    isActive: false,
  ),
  const Account(id: kExternalAccountId, kind: AccountKind.external, label: 'x'),
]);

final _registry = PostingRegistry.standard();
final _at = DateTime.utc(2026, 10, 20, 10);

TransactionDraft _draft(
  TransactionType type,
  int taka, {
  String? from,
  String? to,
  int chargePaisa = 0,
  int commissionPaisa = 0,
  String? note,
}) => TransactionDraft(
  type: type,
  occurredAt: _at,
  amount: Money.taka(taka),
  fromAccountId: from,
  toAccountId: to,
  charge: Money.paisa(chargePaisa),
  commission: Money.paisa(commissionPaisa),
  note: note,
);

Map<String, int> _post(TransactionDraft d) {
  final entries = _registry.strategyFor(d.type).post(d, _accounts);
  expect(
    entries.fold<int>(0, (s, e) => s + e.deltaPaisa),
    0,
    reason: 'entries must balance',
  );
  final byAccount = <String, int>{};
  for (final LedgerEntryDraft e in entries) {
    byAccount[e.accountId] = (byAccount[e.accountId] ?? 0) + e.deltaPaisa;
  }
  return byAccount;
}

void expectCode(void Function() fn, String code) {
  expect(
    fn,
    throwsA(isA<PostingException>().having((e) => e.code, 'code', code)),
  );
}

void main() {
  group('posting (golden)', () {
    test('cash-in: cash up, wallet down', () {
      expect(
        _post(_draft(TransactionType.cashIn, 1000, from: 'bk', to: 'cash')),
        {'bk': -100000, 'cash': 100000},
      );
    });

    test('cash-in with customer fee posts the fee against external', () {
      expect(
        _post(
          _draft(
            TransactionType.cashIn,
            1000,
            from: 'bk',
            to: 'cash',
            chargePaisa: 500,
          ),
        ),
        {'bk': -100000, 'cash': 100500, kExternalAccountId: -500},
      );
    });

    test('cash-out: cash down, wallet up, commission not posted', () {
      expect(
        _post(
          _draft(
            TransactionType.cashOut,
            2000,
            from: 'cash',
            to: 'bk',
            commissionPaisa: 820,
          ),
        ),
        {'cash': -200000, 'bk': 200000},
      );
    });

    test('send money / bill pay mirror cash-in', () {
      for (final t in [TransactionType.sendMoney, TransactionType.billPay]) {
        expect(
          _post(_draft(t, 500, from: 'bk', to: 'cash', chargePaisa: 1000)),
          {'bk': -50000, 'cash': 51000, kExternalAccountId: -1000},
        );
      }
    });

    test('flexiload: sale 100, cost 97, margin 3', () {
      expect(
        _post(
          _draft(
            TransactionType.flexiload,
            100,
            from: 'gp',
            to: 'cash',
            commissionPaisa: 300,
          ),
        ),
        {'gp': -9700, 'cash': 10000, kExternalAccountId: -300},
      );
    });

    test('float purchase from cash or bank', () {
      expect(
        _post(
          _draft(TransactionType.floatPurchase, 50000, from: 'cash', to: 'bk'),
        ),
        {'cash': -5000000, 'bk': 5000000},
      );
      expect(
        _post(
          _draft(TransactionType.floatPurchase, 100, from: 'bank', to: 'gp'),
        ),
        {'bank': -10000, 'gp': 10000},
      );
    });

    test('float transfer with fee leaves the source', () {
      expect(
        _post(
          _draft(
            TransactionType.floatTransfer,
            1000,
            from: 'bk',
            to: 'ng',
            chargePaisa: 1500,
          ),
        ),
        {'bk': -101500, 'ng': 100000, kExternalAccountId: 1500},
      );
    });

    test('bank deposit and withdrawal', () {
      expect(
        _post(
          _draft(TransactionType.bankDeposit, 5000, from: 'cash', to: 'bank'),
        ),
        {'cash': -500000, 'bank': 500000},
      );
      expect(
        _post(
          _draft(TransactionType.bankDeposit, 5000, from: 'bank', to: 'cash'),
        ),
        {'bank': -500000, 'cash': 500000},
      );
    });

    test('expense: cash down, category up', () {
      expect(
        _post(_draft(TransactionType.expense, 350, from: 'cash', to: 'rent')),
        {'cash': -35000, 'rent': 35000},
      );
    });

    test('adjustment up and down against external', () {
      expect(
        _post(
          _draft(
            TransactionType.adjustment,
            5,
            to: 'cash',
            note: 'counting error',
          ),
        ),
        {'cash': 500, kExternalAccountId: -500},
      );
      expect(
        _post(
          _draft(TransactionType.adjustment, 5, from: 'cash', note: 'shortage'),
        ),
        {'cash': -500, kExternalAccountId: 500},
      );
    });
  });

  group('validation', () {
    PostingStrategy s(TransactionType t) => _registry.strategyFor(t);

    test('amount must be positive', () {
      final d = TransactionDraft(
        type: TransactionType.cashOut,
        occurredAt: _at,
        amount: Money.zero,
        fromAccountId: 'cash',
        toAccountId: 'bk',
      );
      expectCode(() => s(d.type).post(d, _accounts), 'amount_not_positive');
    });

    test('missing and unknown accounts', () {
      expectCode(
        () => s(TransactionType.cashOut)
            .post(_draft(TransactionType.cashOut, 10, from: 'cash'), _accounts),
        'missing_to',
      );
      expectCode(
        () => s(TransactionType.cashOut).post(
          _draft(TransactionType.cashOut, 10, from: 'cash', to: 'nope'),
          _accounts,
        ),
        'unknown_to',
      );
    });

    test('wrong account kinds and inactive accounts', () {
      expectCode(
        () => s(TransactionType.cashOut).post(
          _draft(TransactionType.cashOut, 10, from: 'bk', to: 'cash'),
          _accounts,
        ),
        'wrong_kind_from',
      );
      expectCode(
        () => s(TransactionType.cashOut).post(
          _draft(TransactionType.cashOut, 10, from: 'cash', to: 'old'),
          _accounts,
        ),
        'inactive_to',
      );
    });

    test('same account, charges where not allowed', () {
      expectCode(
        () => s(TransactionType.floatTransfer).post(
          _draft(TransactionType.floatTransfer, 10, from: 'bk', to: 'bk'),
          _accounts,
        ),
        'same_account',
      );
      expectCode(
        () => s(TransactionType.cashOut).post(
          _draft(
            TransactionType.cashOut,
            10,
            from: 'cash',
            to: 'bk',
            chargePaisa: 100,
          ),
          _accounts,
        ),
        'charge_not_allowed',
      );
    });

    test('flexiload margin cannot exceed the price', () {
      expectCode(
        () => s(TransactionType.flexiload).post(
          _draft(
            TransactionType.flexiload,
            10,
            from: 'gp',
            to: 'cash',
            commissionPaisa: 1001,
          ),
          _accounts,
        ),
        'margin_exceeds_price',
      );
    });

    test('adjustment needs one side and a reason', () {
      expectCode(
        () => s(TransactionType.adjustment).post(
          _draft(
            TransactionType.adjustment,
            5,
            from: 'cash',
            to: 'bk',
            note: 'x',
          ),
          _accounts,
        ),
        'adjustment_one_side',
      );
      expectCode(
        () => s(TransactionType.adjustment)
            .post(_draft(TransactionType.adjustment, 5, to: 'cash'), _accounts),
        'reason_required',
      );
    });

    test('bank deposit must cross cash and bank', () {
      expectCode(
        () => s(TransactionType.bankDeposit).post(
          _draft(TransactionType.bankDeposit, 5, from: 'cash', to: 'cash'),
          _accounts,
        ),
        'same_account',
      );
    });

    test('every transaction type has a strategy', () {
      for (final t in TransactionType.values) {
        expect(_registry.strategyFor(t).type, t);
      }
    });
  });
}
