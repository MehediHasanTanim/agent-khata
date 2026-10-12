import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Salted PBKDF2-HMAC-SHA256 PIN hashing.
///
/// Encoded form: `pbkdf2-sha256$<iterations>$<salt b64>$<hash b64>`.
class PinHasher {
  PinHasher({this.iterations = 150000, Random? random})
    : _random = random ?? Random.secure();

  final int iterations;
  final Random _random;

  static const _prefix = 'pbkdf2-sha256';

  Future<String> hash(String pin) async {
    final salt = List<int>.generate(16, (_) => _random.nextInt(256));
    final derived = await _derive(pin, salt, iterations);
    return '$_prefix\$$iterations\$${base64.encode(salt)}\$${base64.encode(derived)}';
  }

  Future<bool> verify(String pin, String encoded) async {
    final parts = encoded.split(r'$');
    if (parts.length != 4 || parts[0] != _prefix) return false;
    final iters = int.tryParse(parts[1]);
    if (iters == null || iters <= 0) return false;
    final List<int> salt;
    final List<int> expected;
    try {
      salt = base64.decode(parts[2]);
      expected = base64.decode(parts[3]);
    } on FormatException {
      return false;
    }
    final actual = await _derive(pin, salt, iters);
    return _constantTimeEquals(actual, expected);
  }

  Future<List<int>> _derive(String pin, List<int> salt, int iters) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iters,
      bits: 256,
    );
    final key = await pbkdf2.deriveKeyFromPassword(password: pin, nonce: salt);
    return key.extractBytes();
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
