import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/accounts/account_repository.dart';
import '../features/commission/commission_rule_repository.dart';
import '../features/transactions/transaction_repository.dart';
import 'audit/audit_logger.dart';
import 'bootstrap.dart';
import 'db/app_database.dart';
import 'ledger/strategies.dart';
import 'security/key_value_store.dart';
import 'security/pin_service.dart';
import 'settings/app_preferences.dart';
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
  (ref) => CommissionRuleRepository(ref.watch(databaseProvider)),
);

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
