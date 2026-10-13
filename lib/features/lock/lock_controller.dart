import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/security/pin_service.dart';
import '../../core/security/roles.dart';
import '../staff/staff_service.dart';

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

  /// First-run PIN: this is the owner's PIN.
  Future<void> setPin(String pin) async {
    await _pin.setPin(pin);
    await ref.read(staffServiceProvider).ensureOwner();
    ref.read(sessionProvider.notifier).signIn(Session.owner);
    state = LockStatus.unlocked;
  }

  /// Signs in [userId] (the owner when null). Staff PINs are checked against
  /// their own hash but share the owner's lockout counter.
  Future<PinVerifyResult> unlock(String pin, {String? userId}) async {
    final isStaff = userId != null && userId != kOwnerUserId;
    final staff = ref.read(staffServiceProvider);
    PinVerifyResult result;
    StaffMember? member;
    if (isStaff) {
      member = await staff.byId(userId);
      final hash = await staff.pinHashOf(userId);
      result = await _pin.verifyAgainst(pin, hash);
    } else {
      result = await _pin.verify(pin);
    }
    if (result is PinVerified) {
      await staff.ensureOwner();
      ref
          .read(sessionProvider.notifier)
          .signIn(member?.toSession() ?? Session.owner);
      state = LockStatus.unlocked;
    }
    return result;
  }

  /// Called after a successful system biometric prompt. Biometrics unlock
  /// the owner only, and are not offered once staff accounts exist (any
  /// enrolled fingerprint would otherwise open the owner's session).
  void unlockWithBiometric() {
    if (state == LockStatus.locked) {
      ref.read(sessionProvider.notifier).signIn(Session.owner);
      state = LockStatus.unlocked;
    }
  }

  Future<Duration?> lockoutRemaining() => _pin.lockoutRemaining();

  void lock() {
    if (state == LockStatus.unlocked) {
      ref.read(sessionProvider.notifier).signOut();
      state = LockStatus.locked;
    }
  }
}
