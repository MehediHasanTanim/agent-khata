import 'dart:math';

/// Source of unique string IDs. Injectable so tests can be deterministic.
abstract class IdGenerator {
  String next();
}

/// RFC 9562 UUIDv7: 48-bit Unix-ms timestamp, then random bits. Generated
/// IDs are strictly increasing within one generator, so they sort by time.
class UuidV7Generator implements IdGenerator {
  UuidV7Generator({DateTime Function()? clock, Random? random})
    : _clock = clock ?? DateTime.now,
      _random = random ?? Random.secure();

  final DateTime Function() _clock;
  final Random _random;

  int _lastMs = -1;
  int _seq = 0; // 12-bit counter used as rand_a for same-millisecond IDs

  @override
  String next() {
    var ms = _clock().toUtc().millisecondsSinceEpoch;
    if (ms > _lastMs) {
      _lastMs = ms;
      _seq = _random.nextInt(1 << 11); // leave headroom for increments
    } else {
      ms = _lastMs;
      _seq++;
      if (_seq >= 1 << 12) {
        _lastMs++;
        ms = _lastMs;
        _seq = 0;
      }
    }

    final bytes = List<int>.filled(16, 0);
    for (var i = 0; i < 6; i++) {
      bytes[i] = (ms >> (8 * (5 - i))) & 0xff;
    }
    bytes[6] = 0x70 | ((_seq >> 8) & 0x0f); // version 7 + rand_a high
    bytes[7] = _seq & 0xff;
    bytes[8] = 0x80 | _random.nextInt(0x40); // variant 10
    for (var i = 9; i < 16; i++) {
      bytes[i] = _random.nextInt(256);
    }

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
