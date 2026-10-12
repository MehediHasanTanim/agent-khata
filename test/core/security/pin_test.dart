import 'package:agentkhata/core/security/key_value_store.dart';
import 'package:agentkhata/core/security/lockout_policy.dart';
import 'package:agentkhata/core/security/pin_hasher.dart';
import 'package:agentkhata/core/security/pin_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PinHasher', () {
    final hasher = PinHasher(iterations: 100);

    test('verifies the right PIN and rejects a wrong one', () async {
      final encoded = await hasher.hash('1234');
      expect(await hasher.verify('1234', encoded), isTrue);
      expect(await hasher.verify('1235', encoded), isFalse);
    });

    test('uses a random salt', () async {
      expect(await hasher.hash('1234'), isNot(await hasher.hash('1234')));
    });

    test('rejects malformed encodings', () async {
      expect(await hasher.verify('1234', 'garbage'), isFalse);
      expect(
        await hasher.verify('1234', r'pbkdf2-sha256$x$AA==$AA=='),
        isFalse,
      );
    });
  });

  group('LockoutPolicy', () {
    const policy = LockoutPolicy();
    test('no delay for the first free attempts, then escalates', () {
      expect(policy.delayFor(4), Duration.zero);
      expect(policy.delayFor(5), const Duration(seconds: 30));
      expect(policy.delayFor(6), const Duration(minutes: 1));
      expect(policy.delayFor(7), const Duration(minutes: 5));
      expect(policy.delayFor(8), const Duration(minutes: 15));
      expect(policy.delayFor(50), const Duration(minutes: 15));
    });
    test('attempts before delay', () {
      expect(policy.attemptsBeforeDelay(1), 3);
      expect(policy.attemptsBeforeDelay(9), 0);
    });
  });

  group('PinService', () {
    late MemoryKeyValueStore store;
    late DateTime now;
    late PinService service;

    setUp(() {
      store = MemoryKeyValueStore();
      now = DateTime(2026, 10, 18, 9);
      service = PinService(
        store: store,
        hasher: PinHasher(iterations: 10),
        clock: () => now,
      );
    });

    test('format validation', () {
      expect(PinService.isValidFormat('1234'), isTrue);
      expect(PinService.isValidFormat('123456'), isTrue);
      expect(PinService.isValidFormat('123'), isFalse);
      expect(PinService.isValidFormat('1234567'), isFalse);
      expect(PinService.isValidFormat('12a4'), isFalse);
    });

    test('set, then verify', () async {
      expect(await service.hasPin(), isFalse);
      await service.setPin('4321');
      expect(await service.hasPin(), isTrue);
      expect(await service.verify('4321'), isA<PinVerified>());
      expect(() => service.setPin('12'), throwsArgumentError);
    });

    test(
      'lockout after repeated failures, then clears after the delay',
      () async {
        await service.setPin('4321');
        for (var i = 0; i < 4; i++) {
          final r = await service.verify('0000') as PinWrong;
          expect(r.delay, Duration.zero);
        }
        final fifth = await service.verify('0000') as PinWrong;
        expect(fifth.delay, const Duration(seconds: 30));

        // Even the right PIN is refused while locked out.
        expect(await service.verify('4321'), isA<PinLockedOut>());

        now = now.add(const Duration(seconds: 31));
        expect(await service.verify('4321'), isA<PinVerified>());
        expect(await service.lockoutRemaining(), isNull);
      },
    );
  });
}
