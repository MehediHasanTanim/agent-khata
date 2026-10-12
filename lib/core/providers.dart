import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db/app_database.dart';
import 'security/key_value_store.dart';
import 'security/pin_service.dart';
import 'settings/app_preferences.dart';

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
