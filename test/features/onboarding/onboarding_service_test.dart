import 'package:agentkhata/core/audit/audit_logger.dart';
import 'package:agentkhata/core/db/app_database.dart';
import 'package:agentkhata/core/db/db_settings.dart';
import 'package:agentkhata/core/ledger/account_kind.dart';
import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/features/accounts/account_repository.dart';
import 'package:agentkhata/features/commission/commission_rule.dart';
import 'package:agentkhata/features/commission/commission_rule_repository.dart';
import 'package:agentkhata/features/onboarding/onboarding_service.dart';
import 'package:agentkhata/features/onboarding/provider_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

void main() {
  late AppDatabase db;
  late OnboardingService service;
  late AccountRepository accounts;
  final ids = SequentialIds();

  setUp(() {
    db = AppDatabase.memory();
    accounts = AccountRepository(db, ids);
    service = OnboardingService(
      db: db,
      accounts: accounts,
      rules: CommissionRuleRepository(db, ids, AuditLogger(db, ids)),
    );
  });
  tearDown(() => db.close());

  OnboardingPlan plan() => const OnboardingPlan(
    cashLabel: 'Cash',
    openingCash: Money.taka(12000),
    shopName: '  Rahim Store ',
    accounts: [
      AccountSetup(
        providerId: 'bkash',
        label: 'bKash',
        opening: Money.taka(80000),
      ),
      AccountSetup(providerId: 'gp', label: 'GP', opening: Money.taka(3000)),
    ],
    rates: [
      RateSetup(
        'bkash',
        TransactionType.cashOut,
        CommissionMode.perThousand,
        400,
      ),
      RateSetup('gp', TransactionType.flexiload, CommissionMode.percent, 250),
    ],
    expenseCategories: ['Rent', 'Tea'],
  );

  test('creates accounts, opening balances, rates, categories, shop', () async {
    await service.apply(plan());

    final counted = await accounts.watchCounted().first;
    expect(counted.map((a) => a.label), ['Cash', 'bKash', 'GP']);
    expect(counted.map((a) => a.kind), [
      AccountKind.cash,
      AccountKind.wallet,
      AccountKind.load,
    ]);

    final balances = await accounts.balances();
    expect(balances[counted[0].id], const Money.taka(12000));
    expect(balances[counted[1].id], const Money.taka(80000));
    expect(balances[counted[2].id], const Money.taka(3000));

    final rows = await db.select(db.accounts).get();
    expect(rows.where((a) => a.kind == 'expense'), hasLength(2));
    expect(rows.where((a) => a.id == kExternalAccountIdForTest), hasLength(1));

    expect(await db.select(db.commissionRules).get(), hasLength(2));
    expect(
      await DbSettings(db).get(OnboardingService.shopNameKey),
      'Rahim Store',
    );
  });

  test('is applied at most once', () async {
    await service.apply(plan());
    await expectLater(service.apply(plan()), throwsStateError);
  });

  test('rates are effective for back-dated entries', () async {
    await service.apply(plan());
    final rules = await CommissionRuleRepository(
      db,
      ids,
      AuditLogger(db, ids),
    ).all();
    expect(
      rules.every((r) => r.isEffectiveAt(DateTime.utc(2024, 1, 1))),
      isTrue,
    );
  });

  test(
    'catalog: ids unique, wallets earn cash-out/in, loads earn flexiload',
    () {
      final idsSeen = ProviderCatalog.all.map((p) => p.id).toSet();
      expect(idsSeen, hasLength(ProviderCatalog.all.length));
      for (final w in ProviderCatalog.wallets) {
        expect(w.rateTypes, contains(TransactionType.cashOut));
      }
      for (final o in ProviderCatalog.operators) {
        expect(o.rateTypes, [TransactionType.flexiload]);
      }
      expect(ProviderCatalog.byId('nope'), isNull);
      expect(ProviderCatalog.byId('bkash')?.name('bn'), 'বিকাশ');
    },
  );
}

const kExternalAccountIdForTest = 'sys-external';
