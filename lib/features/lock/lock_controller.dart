import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/security/pin_service.dart';

enum LockStatus { loading, needsSetup, locked, unlocked }

final lockControllerProvider = NotifierProvider<LockController, LockStatus>(
  LockController.new,
);

class LockController extends Notifier<LockStatus> {
  @override
  LockStatus build() {
    _init();
    return LockStatus.loading;
  }

  PinService get _pin => ref.read(pinServiceProvider);

  Future<void> _init() async {
    final has = await _pin.hasPin();
    state = has ? LockStatus.locked : LockStatus.needsSetup;
  }

  Future<void> setPin(String pin) async {
    await _pin.setPin(pin);
    state = LockStatus.unlocked;
  }

  Future<PinVerifyResult> unlock(String pin) async {
    final result = await _pin.verify(pin);
    if (result is PinVerified) state = LockStatus.unlocked;
    return result;
  }

  Future<Duration?> lockoutRemaining() => _pin.lockoutRemaining();

  void lock() {
    if (state == LockStatus.unlocked) state = LockStatus.locked;
  }
}
