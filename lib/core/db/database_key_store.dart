import 'dart:math';

import '../security/key_value_store.dart';

/// Generates and persists the 256-bit database key in the platform keystore.
class DatabaseKeyStore {
  DatabaseKeyStore(this._store, {Random? random})
    : _random = random ?? Random.secure();

  static const _keyName = 'db_key_v1';

  final KeyValueStore _store;
  final Random _random;

  /// Returns the key as 64 hex characters, creating it on first use.
  Future<String> getOrCreateKeyHex() async {
    final existing = await _store.read(_keyName);
    if (existing != null && existing.length == 64) return existing;
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _store.write(_keyName, hex);
    return hex;
  }
}
