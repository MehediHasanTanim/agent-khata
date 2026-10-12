import 'package:local_auth/local_auth.dart';

/// Fingerprint / face unlock. Always a convenience on top of the PIN, never a
/// replacement, and all failures are soft ("not available").
abstract class BiometricService {
  /// Device has biometric hardware with something enrolled.
  Future<bool> isAvailable();

  /// Shows the system prompt; true when the user authenticated.
  Future<bool> authenticate(String reason);
}

class LocalAuthBiometricService implements BiometricService {
  LocalAuthBiometricService([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      if (!await _auth.canCheckBiometrics) return false;
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
    } on Object {
      return false;
    }
  }
}
