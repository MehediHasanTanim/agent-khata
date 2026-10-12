import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/accounts/account_repository.dart';
import '../features/closeday/day_close_service.dart';
import '../features/commission/commission_rule.dart';
import '../features/commission/commission_rule_repository.dart';
import '../features/customers/customer_repository.dart';
import '../features/onboarding/onboarding_service.dart';
import '../features/transactions/history_queries.dart';
import '../features/transactions/transaction_queries.dart';
import '../features/transactions/transaction_repository.dart';
import 'audit/audit_logger.dart';
import 'bootstrap.dart';
import 'db/app_database.dart';
import 'db/db_settings.dart';
import 'ledger/account.dart';
import 'ledger/strategies.dart';
import 'money/money.dart';
import 'notifications/notification_service.dart';
import 'security/biometric_service.dart';
import 'security/key_value_store.dart';
import 'security/pin_service.dart';
import 'security/secure_screen.dart';
import 'settings/app_preferences.dart';
import 'telemetry/analytics.dart';
import 'telemetry/crash_log.dart';
import 'utils/business_calendar.dart';
import 'utils/uuid_v7.dart';

/// Overridden in `bootstrap()` once SharedPreferences has loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

/// Overridden in `bootstrap()` with the opened encrypted database.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider not overridden'),
);

final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => const SecureKeyValueStore(),
);

final pinServiceProvider = Provider<PinService>(
  (ref) => PinService(store: ref.watch(keyValueStoreProvider)),
);

final preferencesProvider =
    NotifierProvider<PreferencesController, AppPreferences>(
      PreferencesController.new,
    );

class PreferencesController extends Notifier<AppPreferences> {
  @override
  AppPreferences build() =>
      AppPreferences.load(ref.watch(sharedPreferencesProvider));

  Future<void> update(AppPreferences Function(AppPreferences) change) async {
    state = change(state);
    await state.save(ref.read(sharedPreferencesProvider));
  }
}

/// Overridden in `bootstrap()`.
final flavorProvider = Provider<Flavor>((ref) => Flavor.prod);

final idGeneratorProvider = Provider<IdGenerator>((ref) => UuidV7Generator());

final auditLoggerProvider = Provider<AuditLogger>(
  (ref) =>
      AuditLogger(ref.watch(databaseProvider), ref.watch(idGeneratorProvider)),
);

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(
    ref.watch(databaseProvider),
    ref.watch(idGeneratorProvider),
  ),
);

final commissionRuleRepositoryProvider = Provider<CommissionRuleRepository>(
  (ref) => CommissionRuleRepository(
    ref.watch(databaseProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(auditLoggerProvider),
  ),
);

final transactionQueriesProvider = Provider<TransactionQueries>(
  (ref) => TransactionQueries(ref.watch(databaseProvider)),
);

final onboardingServiceProvider = Provider<OnboardingService>(
  (ref) => OnboardingService(
    db: ref.watch(databaseProvider),
    accounts: ref.watch(accountRepositoryProvider),
    rules: ref.watch(commissionRuleRepositoryProvider),
  ),
);

/// Counted accounts (cash, wallets, loads, bank), live.
final accountsProvider = StreamProvider<List<Account>>(
  (ref) => ref.watch(accountRepositoryProvider).watchCounted(),
);

/// Live balance of every account, keyed by account id.
final balancesProvider = StreamProvider<Map<String, Money>>(
  (ref) => ref.watch(accountRepositoryProvider).watchBalances(),
);

final commissionRulesProvider = StreamProvider<List<CommissionRule>>(
  (ref) => ref.watch(commissionRuleRepositoryProvider).watchAll(),
);

/// Whether first-run onboarding has been completed.
final onboardingDoneProvider = NotifierProvider<OnboardingDone, bool>(
  OnboardingDone.new,
);

class OnboardingDone extends Notifier<bool> {
  static const _key = 'onboarding_done';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> complete() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
  }
}

final postingRegistryProvider = Provider<PostingRegistry>(
  (ref) => PostingRegistry.standard(),
);

/// Stable per-install id stamped on every transaction (future sync).
final deviceIdProvider = Provider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  const key = 'device_id';
  final existing = prefs.getString(key);
  if (existing != null) return existing;
  final id = ref.read(idGeneratorProvider).next();
  prefs.setString(key, id);
  return id;
});

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(
    db: ref.watch(databaseProvider),
    registry: ref.watch(postingRegistryProvider),
    ids: ref.watch(idGeneratorProvider),
    audit: ref.watch(auditLoggerProvider),
    deviceId: ref.watch(deviceIdProvider),
  ),
);

/// Business-day rollover hour from the `setting` table.
final dayRolloverHourProvider = FutureProvider<int>(
  (ref) => DbSettings(ref.watch(databaseProvider)).dayRolloverHour(),
);

final historyQueriesProvider = Provider<HistoryQueries>(
  (ref) => HistoryQueries(ref.watch(databaseProvider)),
);

final accountLedgerQueriesProvider = Provider<AccountLedgerQueries>(
  (ref) => AccountLedgerQueries(ref.watch(databaseProvider)),
);

final transactionDetailLoaderProvider = Provider<TransactionDetailLoader>(
  (ref) => TransactionDetailLoader(
    ref.watch(databaseProvider),
    ref.watch(historyQueriesProvider),
  ),
);

final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => CustomerRepository(
    ref.watch(databaseProvider),
    ref.watch(idGeneratorProvider),
  ),
);

final dayCloseServiceProvider = Provider<DayCloseService>(
  (ref) => DayCloseService(
    db: ref.watch(databaseProvider),
    txns: ref.watch(transactionRepositoryProvider),
    audit: ref.watch(auditLoggerProvider),
    ids: ref.watch(idGeneratorProvider),
  ),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

/// Business date of yesterday if it has entries but was not closed.
final unclosedYesterdayProvider = FutureProvider.autoDispose<String?>((
  ref,
) async {
  // Re-check whenever the ledger changes.
  ref.watch(balancesProvider);
  final db = ref.watch(databaseProvider);
  final hour = await ref.watch(dayRolloverHourProvider.future);
  final cal = BusinessCalendar(rolloverHour: hour);
  final today = cal.businessDateOf(DateTime.now().toUtc());
  final yesterday = cal.previousDate(today);
  final range = cal.rangeOfDate(yesterday);

  final closed = await (db.select(
    db.dayCloses,
  )..where((t) => t.businessDate.equals(yesterday))).getSingleOrNull();
  if (closed != null && closed.status == 'closed') return null;

  final any = await db
      .customSelect(
        "SELECT 1 FROM txn WHERE status = 'active' AND type <> 'adjustment' "
        'AND occurred_at >= ? AND occurred_at < ? LIMIT 1',
        variables: [
          Variable.withInt(range.start.millisecondsSinceEpoch),
          Variable.withInt(range.end.millisecondsSinceEpoch),
        ],
        readsFrom: {db.txns},
      )
      .get();
  return any.isEmpty ? null : yesterday;
});

final biometricServiceProvider = Provider<BiometricService>(
  (ref) => LocalAuthBiometricService(),
);

final secureScreenProvider = Provider<SecureScreen>(
  (ref) => const SecureScreen(),
);

/// Overridden in `bootstrap()` with the on-device crash log.
final crashLogProvider = Provider<CrashLog?>((ref) => null);

/// Overridden in `bootstrap()`; a no-op sink when not available.
final analyticsProvider = Provider<AnalyticsSink>(
  (ref) => const NoopAnalytics(),
);

/// Analytics event counts for the diagnostics report.
final analyticsCountsProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  final sink = ref.watch(analyticsProvider);
  return sink is LocalFileAnalytics ? sink.counts() : <String, int>{};
});

final shopNameProvider = FutureProvider.autoDispose<String>((ref) async {
  final v = await DbSettings(ref.watch(databaseProvider)).get('shop_name');
  return v ?? '';
});
