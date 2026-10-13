import 'key_value_store.dart';
import 'lockout_policy.dart';
import 'pin_hasher.dart';

sealed class PinVerifyResult {
  const PinVerifyResult();
}

class PinVerified extends PinVerifyResult {
  const PinVerified();
}

class PinWrong extends PinVerifyResult {
  const PinWrong({required this.attemptsBeforeDelay, required this.delay});

  /// Free attempts left before a delay applies (0 once a delay is active).
  final int attemptsBeforeDelay;

  /// Delay now imposed (zero while free attempts remain).
  final Duration delay;
}

class PinLockedOut extends PinVerifyResult {
  const PinLockedOut(this.remaining);
  final Duration remaining;
}

/// Stores the PIN hash and failed-attempt state in secure storage.
class PinService {
  PinService({
    required this._store,
    PinHasher? hasher,
    this._policy = const LockoutPolicy(),
    DateTime Function()? clock,
  }) : _hasher = hasher ?? PinHasher(),
       _clock = clock ?? DateTime.now;

  static const minLength = 4;
  static const maxLength = 6;

  static const _hashKey = 'pin_hash_v1';
  static const _failuresKey = 'pin_failures_v1';
  static const _lockedUntilKey = 'pin_locked_until_v1';

  final KeyValueStore _store;
  final PinHasher _hasher;
  final LockoutPolicy _policy;
  final DateTime Function() _clock;

  static bool isValidFormat(String pin) =>
      RegExp('^\\d{$minLength,$maxLength}\$').hasMatch(pin);

  Future<bool> hasPin() async => (await _store.read(_hashKey)) != null;

  Future<void> setPin(String pin) async {
    if (!isValidFormat(pin)) {
      throw ArgumentError.value(pin, 'pin', 'must be 4 to 6 digits');
    }
    await _store.write(_hashKey, await _hasher.hash(pin));
    await _clearFailures();
  }

  /// Remaining lockout, or `null` when entry is allowed.
  Future<Duration?> lockoutRemaining() async {
    final raw = await _store.read(_lockedUntilKey);
    final until = raw == null ? null : int.tryParse(raw);
    if (until == null) return null;
    final remaining = DateTime.fromMillisecondsSinceEpoch(until)
        .difference(_clock());
    return remaining > Duration.zero ? remaining : null;
  }

  Future<PinVerifyResult> verify(String pin) async =>
      verifyAgainst(pin, await _store.read(_hashKey));

  /// True if [pin] is the owner's PIN. Does not touch the failure counter
  /// (used to keep staff PINs distinct from the owner's).
  Future<bool> matchesOwnerPin(String pin) async {
    final stored = await _store.read(_hashKey);
    return stored != null && await _hasher.verify(pin, stored);
  }

  /// Compares [pin] with an encoded hash made by [hashPin].
  Future<bool> verifyHash(String pin, String encoded) =>
      _hasher.verify(pin, encoded);

  /// Hashes a PIN for storage elsewhere (staff accounts).
  Future<String> hashPin(String pin) => _hasher.hash(pin);

  /// Checks [pin] against any stored hash (a staff member's, say) while
  /// sharing the owner's lockout and failure counter, so guessing across
  /// accounts gains nothing.
  Future<PinVerifyResult> verifyAgainst(String pin, String? stored) async {
    final remaining = await lockoutRemaining();
    if (remaining != null) return PinLockedOut(remaining);

    if (stored != null && await _hasher.verify(pin, stored)) {
      await _clearFailures();
      return const PinVerified();
    }

    final failures = await _failures() + 1;
    await _store.write(_failuresKey, failures.toString());
    final delay = _policy.delayFor(failures);
    if (delay > Duration.zero) {
      final until = _clock().add(delay).millisecondsSinceEpoch;
      await _store.write(_lockedUntilKey, until.toString());
    }
    return PinWrong(
      attemptsBeforeDelay: _policy.attemptsBeforeDelay(failures),
      delay: delay,
    );
  }

  Future<int> _failures() async =>
      int.tryParse(await _store.read(_failuresKey) ?? '') ?? 0;

  Future<void> _clearFailures() async {
    await _store.delete(_failuresKey);
    await _store.delete(_lockedUntilKey);
  }
}
