import 'dart:convert';
import 'dart:io' show GZipCodec;
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Raised for any backup file problem. [code] is stable for UI mapping.
class BackupException implements Exception {
  const BackupException(this.code, [this.detail]);

  /// `bad_file`, `unsupported_format`, `newer_schema`, `wrong_passphrase`,
  /// `corrupt`, `weak_passphrase`.
  final String code;
  final String? detail;

  @override
  String toString() =>
      'BackupException($code${detail == null ? '' : ': $detail'})';
}

/// Argon2id cost parameters, stored in the backup header so a file can always
/// be opened later even if the defaults change.
class KdfParams {
  const KdfParams({
    this.memoryKiB = 19456,
    this.iterations = 2,
    this.parallelism = 1,
  });

  /// OWASP's minimum recommendation for Argon2id; kept modest so low-end
  /// phones finish in a few seconds.
  static const standard = KdfParams();

  /// Tiny parameters for unit tests only.
  static const testing = KdfParams(memoryKiB: 64, iterations: 1);

  final int memoryKiB;
  final int iterations;
  final int parallelism;

  Map<String, Object?> toJson() => {
    'name': 'argon2id',
    'memory_kib': memoryKiB,
    'iterations': iterations,
    'parallelism': parallelism,
  };

  /// Parses and bounds-checks header values (a hostile file must not be able
  /// to demand gigabytes of memory).
  static KdfParams fromJson(Map<String, Object?> json) {
    if (json['name'] != 'argon2id') {
      throw const BackupException('unsupported_format', 'kdf');
    }
    final m = json['memory_kib'];
    final i = json['iterations'];
    final p = json['parallelism'];
    if (m is! int || i is! int || p is! int) {
      throw const BackupException('bad_file', 'kdf params');
    }
    if (m < 8 || m > 262144 || i < 1 || i > 10 || p < 1 || p > 8) {
      throw const BackupException('bad_file', 'kdf params out of range');
    }
    return KdfParams(memoryKiB: m, iterations: i, parallelism: p);
  }
}

class BackupHeader {
  const BackupHeader({
    required this.formatVersion,
    required this.schemaVersion,
    required this.appVersion,
    required this.deviceId,
    required this.createdAt,
    required this.kdf,
    required this.salt,
    required this.nonce,
    required this.payloadSha256,
    required this.payloadLength,
  });

  final int formatVersion;
  final int schemaVersion;
  final String appVersion;
  final String deviceId;
  final DateTime createdAt;
  final KdfParams kdf;
  final List<int> salt;
  final List<int> nonce;

  /// SHA-256 (base64) of the compressed payload, checked after decryption.
  final String payloadSha256;
  final int payloadLength;

  Map<String, Object?> toJson() => {
    'format_version': formatVersion,
    'schema_version': schemaVersion,
    'app_version': appVersion,
    'device_id': deviceId,
    'created_at': createdAt.toUtc().toIso8601String(),
    'kdf': kdf.toJson(),
    'salt': base64.encode(salt),
    'nonce': base64.encode(nonce),
    'payload_sha256': payloadSha256,
    'payload_length': payloadLength,
  };

  static BackupHeader fromJson(Map<String, Object?> j) {
    try {
      return BackupHeader(
        formatVersion: j['format_version']! as int,
        schemaVersion: j['schema_version']! as int,
        appVersion: j['app_version']! as String,
        deviceId: j['device_id']! as String,
        createdAt: DateTime.parse(j['created_at']! as String),
        kdf: KdfParams.fromJson(
          Map<String, Object?>.from(j['kdf']! as Map<dynamic, dynamic>),
        ),
        salt: base64.decode(j['salt']! as String),
        nonce: base64.decode(j['nonce']! as String),
        payloadSha256: j['payload_sha256']! as String,
        payloadLength: j['payload_length']! as int,
      );
    } on BackupException {
      rethrow;
    } on Object {
      throw const BackupException('bad_file', 'header');
    }
  }
}

/// `.cbk` container:
///
/// ```
/// "AKCBK1\n"            7 bytes magic
/// uint32 BE             header length N
/// N bytes               header JSON (UTF-8, authenticated as AES-GCM AAD)
/// rest                  AES-256-GCM ciphertext followed by the 16-byte tag
/// ```
///
/// The key is Argon2id(passphrase, salt). The passphrase is never stored: a
/// lost passphrase means the backup cannot be opened.
class BackupCodec {
  const BackupCodec();

  static const formatVersion = 1;
  static const minPassphraseLength = 6;
  static final List<int> _magic = utf8.encode('AKCBK1\n');
  static const _macLength = 16;

  static final AesGcm _cipher = AesGcm.with256bits();

  /// Compresses, encrypts and wraps [payloadJson].
  Future<Uint8List> encode({
    required List<int> payloadJson,
    required String passphrase,
    required int schemaVersion,
    required String appVersion,
    required String deviceId,
    required DateTime createdAt,
    KdfParams kdf = KdfParams.standard,
  }) async {
    if (passphrase.length < minPassphraseLength) {
      throw const BackupException('weak_passphrase');
    }
    final compressed = GZipCodec().encode(payloadJson);
    final salt = _random(16);
    final nonce = _random(12);
    final header = BackupHeader(
      formatVersion: formatVersion,
      schemaVersion: schemaVersion,
      appVersion: appVersion,
      deviceId: deviceId,
      createdAt: createdAt,
      kdf: kdf,
      salt: salt,
      nonce: nonce,
      payloadSha256: base64.encode((await Sha256().hash(compressed)).bytes),
      payloadLength: compressed.length,
    );
    final headerBytes = utf8.encode(jsonEncode(header.toJson()));
    final key = await _deriveKey(passphrase, salt, kdf);
    final box = await _cipher.encrypt(
      compressed,
      secretKey: SecretKey(key),
      nonce: nonce,
      aad: headerBytes,
    );

    final out = BytesBuilder()
      ..add(_magic)
      ..add(
        (ByteData(4)..setUint32(0, headerBytes.length)).buffer.asUint8List(),
      )
      ..add(headerBytes)
      ..add(box.cipherText)
      ..add(box.mac.bytes);
    return out.toBytes();
  }

  /// Reads the header without a passphrase (for "this backup is from ...").
  BackupHeader readHeader(Uint8List file) => _split(file).header;

  /// Decrypts and decompresses; returns the payload JSON bytes.
  Future<Uint8List> decode(Uint8List file, String passphrase) async {
    final parts = _split(file);
    final header = parts.header;
    if (header.formatVersion != formatVersion) {
      throw const BackupException('unsupported_format', 'format version');
    }
    final body = parts.body;
    if (body.length < _macLength) throw const BackupException('bad_file');
    final cipherText = body.sublist(0, body.length - _macLength);
    final mac = Mac(body.sublist(body.length - _macLength));

    final key = await _deriveKey(passphrase, header.salt, header.kdf);
    final List<int> compressed;
    try {
      compressed = await _cipher.decrypt(
        SecretBox(cipherText, nonce: header.nonce, mac: mac),
        secretKey: SecretKey(key),
        aad: parts.headerBytes,
      );
    } on SecretBoxAuthenticationError {
      // Wrong passphrase or any tampering with header/body.
      throw const BackupException('wrong_passphrase');
    }

    final digest = base64.encode((await Sha256().hash(compressed)).bytes);
    if (digest != header.payloadSha256 ||
        compressed.length != header.payloadLength) {
      throw const BackupException('corrupt', 'checksum');
    }
    try {
      return Uint8List.fromList(GZipCodec().decode(compressed));
    } on Object {
      throw const BackupException('corrupt', 'gzip');
    }
  }

  ({BackupHeader header, List<int> headerBytes, Uint8List body}) _split(
    Uint8List file,
  ) {
    if (file.length < _magic.length + 4) {
      throw const BackupException('bad_file', 'too short');
    }
    for (var i = 0; i < _magic.length; i++) {
      if (file[i] != _magic[i]) {
        throw const BackupException('bad_file', 'magic');
      }
    }
    final length = ByteData.sublistView(
      file,
      _magic.length,
      _magic.length + 4,
    ).getUint32(0);
    final start = _magic.length + 4;
    if (length == 0 || length > 4096 || start + length > file.length) {
      throw const BackupException('bad_file', 'header length');
    }
    final headerBytes = file.sublist(start, start + length);
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(headerBytes));
    } on Object {
      throw const BackupException('bad_file', 'header json');
    }
    if (decoded is! Map) throw const BackupException('bad_file', 'header');
    final header = BackupHeader.fromJson(Map<String, Object?>.from(decoded));
    return (
      header: header,
      headerBytes: headerBytes,
      body: file.sublist(start + length),
    );
  }

  static List<int> _random(int n) {
    final r = Random.secure();
    return List<int>.generate(n, (_) => r.nextInt(256));
  }
}

/// Argon2id in a background isolate so the UI does not freeze.
Future<List<int>> _deriveKey(String passphrase, List<int> salt, KdfParams kdf) {
  return Isolate.run(() async {
    final argon = Argon2id(
      memory: kdf.memoryKiB,
      parallelism: kdf.parallelism,
      iterations: kdf.iterations,
      hashLength: 32,
    );
    final key = await argon.deriveKeyFromPassword(
      password: passphrase,
      nonce: salt,
    );
    return key.extractBytes();
  });
}
