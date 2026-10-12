import 'package:agentkhata/core/db/app_database.dart';
import 'package:agentkhata/core/db/database_key_store.dart';
import 'package:agentkhata/core/security/key_value_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('in-memory database opens at schema v1', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final info = await db.info();
    expect(info.userVersion, 1);
  });

  test('database key is 256-bit hex and stable across calls', () async {
    final store = MemoryKeyValueStore();
    final keys = DatabaseKeyStore(store);
    final first = await keys.getOrCreateKeyHex();
    expect(first, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(await DatabaseKeyStore(store).getOrCreateKeyHex(), first);
  });

  test('openEncryptedDatabase rejects malformed keys', () {
    expect(() => openEncryptedDatabase('abc'), throwsArgumentError);
  });
}
