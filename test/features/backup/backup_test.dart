import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:agentkhata/core/db/app_database.dart';
import 'package:agentkhata/features/backup/backup_codec.dart';
import 'package:agentkhata/features/backup/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

void main() {
  const codec = BackupCodec();
  const pass = 'correct horse';

  Future<Uint8List> encode(List<int> payload, {String passphrase = pass}) =>
      codec.encode(
        payloadJson: payload,
        passphrase: passphrase,
        schemaVersion: 3,
        appVersion: '0.1.0',
        deviceId: 'dev-1',
        createdAt: DateTime.utc(2026, 10, 20, 12),
        kdf: KdfParams.testing,
      );

  group('codec', () {
    test('round trip and readable header', () async {
      final payload = utf8.encode('{"hello":"৳ বাংলা"}');
      final file = await encode(payload);
      expect(await codec.decode(file, pass), payload);

      final h = codec.readHeader(file);
      expect(h.schemaVersion, 3);
      expect(h.appVersion, '0.1.0');
      expect(h.deviceId, 'dev-1');
      expect(h.createdAt, DateTime.utc(2026, 10, 20, 12));
    });

    test('plaintext does not appear in the file', () async {
      final file = await encode(utf8.encode('SECRET-LEDGER-MARKER' * 20));
      expect(
        utf8.decode(file, allowMalformed: true),
        isNot(contains('SECRET')),
      );
    });

    test('wrong passphrase is reported as such', () async {
      final file = await encode(utf8.encode('{}'));
      await expectLater(
        codec.decode(file, 'wrong pass'),
        throwsA(
          isA<BackupException>().having(
            (e) => e.code,
            'code',
            'wrong_passphrase',
          ),
        ),
      );
    });

    test('tampering with ciphertext or header is detected', () async {
      final file = await encode(utf8.encode('{"a":1}'));
      final body = Uint8List.fromList(file)..[file.length - 20] ^= 0x01;
      await expectLater(
        codec.decode(body, pass),
        throwsA(isA<BackupException>()),
      );

      // Flip a byte inside the header JSON (changes the AAD).
      final headerTampered = Uint8List.fromList(file);
      final idx = headerTampered.indexOf(utf8.encode('dev-1').first);
      headerTampered[idx + 1] ^= 0x01;
      await expectLater(
        codec.decode(headerTampered, pass),
        throwsA(isA<BackupException>()),
      );
    });

    test('rejects non-backup files and truncation', () async {
      expect(
        () => codec.readHeader(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<BackupException>()),
      );
      expect(
        () => codec.readHeader(Uint8List.fromList(List.filled(64, 7))),
        throwsA(isA<BackupException>()),
      );
      final file = await encode(utf8.encode('{}'));
      await expectLater(
        codec.decode(file.sublist(0, 30), pass),
        throwsA(isA<BackupException>()),
      );
    });

    test('weak passphrases are refused', () async {
      await expectLater(
        encode(utf8.encode('{}'), passphrase: '123'),
        throwsA(
          isA<BackupException>().having(
            (e) => e.code,
            'code',
            'weak_passphrase',
          ),
        ),
      );
    });

    test('hostile KDF parameters in a header are bounded', () {
      expect(
        () => KdfParams.fromJson({
          'name': 'argon2id',
          'memory_kib': 4000000,
          'iterations': 2,
          'parallelism': 1,
        }),
        throwsA(isA<BackupException>()),
      );
    });
  });

  group('service', () {
    late LedgerFixture f;
    late BackupService service;

    setUp(() async {
      f = await LedgerFixture.create();
      service = BackupService(
        db: f.db,
        appVersion: '0.1.0',
        deviceId: 'dev-1',
        clock: f.clock,
      );
      await f.txns.post(f.cashOutDraft(2000));
      final id = await f.txns.post(f.cashInDraft(500));
      await f.txns.voidTransaction(id, reason: 'oops', userId: 'owner');
      await f.txns.post(f.cashOutDraft(750, wallet: f.nagad));
    });
    tearDown(() => f.dispose());

    test(
      'backup then restore reproduces the logical content exactly',
      () async {
        final file = await service.createBackup(pass, kdf: KdfParams.testing);
        final target = AppDatabase.memory();
        addTearDown(target.close);

        await service.restoreInto(target, file, pass);

        final original = await service.dumpTables();
        final restored = await BackupService(
          db: target,
          appVersion: 'x',
          deviceId: 'y',
        ).dumpTables();
        expect(jsonEncode(restored), jsonEncode(original));

        // And the books agree.
        final a = await f.accounts.balances();
        final targetBalances = await target
            .customSelect(
              "SELECT a.id, a.opening_paisa + COALESCE((SELECT SUM(le.delta_paisa) FROM ledger_entry le JOIN txn t ON t.id = le.txn_id WHERE le.account_id = a.id AND t.status = 'active'), 0) AS b FROM account a",
            )
            .get();
        for (final r in targetBalances) {
          expect(r.read<int>('b'), a[r.read<String>('id')]!.paisa);
        }
      },
    );

    test('inspect needs no passphrase', () async {
      final file = await service.createBackup(pass, kdf: KdfParams.testing);
      final info = service.inspect(file);
      expect(info.schemaVersion, f.db.schemaVersion);
      expect(info.deviceId, 'dev-1');
    });

    test('a newer-schema backup is rejected with a clear code', () async {
      final newer = await codec.encode(
        payloadJson: utf8.encode('{"tables":{}}'),
        passphrase: pass,
        schemaVersion: 99,
        appVersion: '9.9.9',
        deviceId: 'd',
        createdAt: DateTime.utc(2030),
        kdf: KdfParams.testing,
      );
      final target = AppDatabase.memory();
      addTearDown(target.close);
      await expectLater(
        service.restoreInto(target, newer, pass),
        throwsA(
          isA<BackupException>().having((e) => e.code, 'code', 'newer_schema'),
        ),
      );
    });

    test('an older-schema backup (missing tables) restores', () async {
      final payload = {
        'format': 1,
        'schema_version': 2,
        'tables': {
          'account': [
            {
              'id': 'a1',
              'kind': 'cash',
              'label': 'Cash',
              'opening_paisa': 5000,
              'is_active': 1,
              'sort_order': 0,
              'created_at': 0,
            },
          ],
        },
      };
      final file = await codec.encode(
        payloadJson: utf8.encode(jsonEncode(payload)),
        passphrase: pass,
        schemaVersion: 2,
        appVersion: '0.0.9',
        deviceId: 'old',
        createdAt: DateTime.utc(2026),
        kdf: KdfParams.testing,
      );
      final target = AppDatabase.memory();
      addTearDown(target.close);
      await service.restoreInto(target, file, pass);
      final rows = await target.select(target.accounts).get();
      expect(rows.single.openingPaisa, 5000);
    });

    test('a payload that fails the integrity check is refused', () async {
      final payload = {
        'format': 1,
        'schema_version': 3,
        'tables': {
          'account': [
            {'id': 'a1', 'kind': 'cash', 'label': 'C', 'created_at': 0},
          ],
          'txn': [
            {
              'id': 't1',
              'type': 'cash_out',
              'occurred_at': 0,
              'recorded_at': 0,
              'amount_paisa': 100,
              'created_by': 'o',
              'device_id': 'd',
            },
          ],
          'ledger_entry': [
            {
              'id': 'l1',
              'txn_id': 't1',
              'account_id': 'a1',
              'delta_paisa': 100,
              'line_no': 0,
            },
          ],
        },
      };
      final file = await codec.encode(
        payloadJson: utf8.encode(jsonEncode(payload)),
        passphrase: pass,
        schemaVersion: 3,
        appVersion: '0.1.0',
        deviceId: 'd',
        createdAt: DateTime.utc(2026),
        kdf: KdfParams.testing,
      );
      final target = AppDatabase.memory();
      addTearDown(target.close);
      await expectLater(
        service.restoreInto(target, file, pass),
        throwsA(
          isA<BackupException>().having((e) => e.code, 'code', 'corrupt'),
        ),
      );
    });
  });

  group('staged restore swap', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('akbk'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('keeps the old database and installs the staged one', () async {
      File('${dir.path}/khata.db').writeAsStringSync('OLD');
      File('${dir.path}/khata.db-wal').writeAsStringSync('OLD-WAL');
      File('${dir.path}/khata.restore.db').writeAsStringSync('NEW');
      await BackupService.markPending(dir, 'khata.restore.db');

      expect(await BackupService.applyPending(dir, 'khata.db'), isTrue);
      expect(File('${dir.path}/khata.db').readAsStringSync(), 'NEW');
      expect(
        File('${dir.path}/khata.db.pre-restore').readAsStringSync(),
        'OLD',
      );
      expect(File('${dir.path}/khata.db-wal').existsSync(), isFalse);
      expect(File('${dir.path}/restore.pending').existsSync(), isFalse);
    });

    test('no marker, nothing happens', () async {
      File('${dir.path}/khata.db').writeAsStringSync('OLD');
      expect(await BackupService.applyPending(dir, 'khata.db'), isFalse);
      expect(File('${dir.path}/khata.db').readAsStringSync(), 'OLD');
    });

    test('a missing staged file leaves the live database alone', () async {
      File('${dir.path}/khata.db').writeAsStringSync('OLD');
      await BackupService.markPending(dir, 'gone.db');
      expect(await BackupService.applyPending(dir, 'khata.db'), isFalse);
      expect(File('${dir.path}/khata.db').readAsStringSync(), 'OLD');
    });
  });
}
