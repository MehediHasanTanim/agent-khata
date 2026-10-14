import '../../core/audit/audit_logger.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_settings.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/utils/uuid_v7.dart';
import '../accounts/account_repository.dart';
import '../commission/commission_rule.dart';
import '../commission/commission_rule_repository.dart';
import 'provider_catalog.dart';

class AccountSetup {
  const AccountSetup({
    required this.providerId,
    required this.label,
    this.opening = Money.zero,
  });

  final String providerId;
  final String label;
  final Money opening;
}

class RateSetup {
  const RateSetup(
    this.providerId,
    this.type,
    this.mode,
    this.value, {
    this.tiers = const [],
  });

  final String providerId;
  final TransactionType type;
  final CommissionMode mode;
  final int value;
  final List<CommissionTier> tiers;
}

/// Everything onboarding collects, applied in one DB transaction.
class OnboardingPlan {
  const OnboardingPlan({
    required this.cashLabel,
    required this.accounts,
    required this.rates,
    required this.expenseCategories,
    this.openingCash = Money.zero,
    this.shopName = '',
  });

  final String cashLabel;
  final Money openingCash;
  final List<AccountSetup> accounts;
  final List<RateSetup> rates;
  final List<String> expenseCategories;
  final String shopName;
}

/// First-run setup. It runs before anyone has signed in (the PIN comes after
/// onboarding), so it must not depend on a signed-in session: it creates its
/// own commission-rule repository without permission checks. Setup is the
/// owner's by definition.
class OnboardingService {
  OnboardingService({
    required this._db,
    required this._accounts,
    required IdGenerator ids,
    required AuditLogger audit,
  }) : _rules = CommissionRuleRepository(_db, ids, audit);

  final AppDatabase _db;
  final AccountRepository _accounts;
  final CommissionRuleRepository _rules;

  /// Rates start far in the past so back-dated entries still get a rate.
  static final ratesEffectiveFrom = DateTime.utc(2000);

  static const shopNameKey = 'shop_name';

  Future<void> apply(OnboardingPlan plan) {
    return _db.transaction(() async {
      final existing = await _db.select(_db.accounts).get();
      if (existing.any((a) => a.kind == AccountKind.cash.dbName)) {
        throw StateError('Onboarding was already applied');
      }
      await _accounts.ensureSystemAccounts();
      await _accounts.create(
        kind: AccountKind.cash,
        label: plan.cashLabel,
        opening: plan.openingCash,
        sortOrder: 0,
      );
      var order = 1;
      for (final a in plan.accounts) {
        final info = ProviderCatalog.byId(a.providerId);
        await _accounts.create(
          kind: info?.kind ?? AccountKind.wallet,
          label: a.label,
          provider: a.providerId,
          opening: a.opening,
          sortOrder: order++,
        );
      }
      for (final r in plan.rates) {
        await _rules.setRate(
          provider: r.providerId,
          type: r.type,
          mode: r.mode,
          value: r.value,
          tiers: r.tiers,
          at: ratesEffectiveFrom,
        );
      }
      for (final name in plan.expenseCategories) {
        await _accounts.create(kind: AccountKind.expense, label: name);
      }
      if (plan.shopName.trim().isNotEmpty) {
        await DbSettings(_db).set(shopNameKey, plan.shopName.trim());
      }
    });
  }
}
