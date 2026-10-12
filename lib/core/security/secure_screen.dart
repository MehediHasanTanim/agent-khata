import 'package:flutter/services.dart';

/// Turns Android's FLAG_SECURE on or off (no screenshots, blank preview in
/// the recents list). Failing quietly keeps tests and other platforms fine.
class SecureScreen {
  const SecureScreen();

  static const _channel = MethodChannel('com.nextgenai.agentkhata/secure');

  Future<void> set({required bool secure}) async {
    try {
      await _channel.invokeMethod<void>('setSecure', secure);
    } on MissingPluginException {
      // Not running on Android.
    } on PlatformException {
      // Best effort.
    }
  }
}
