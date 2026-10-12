import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'lock_controller.dart';
import 'pin_screen.dart';

/// Shows [child] only while the app is unlocked, and locks the app when it
/// has been in the background longer than the configured timeout.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final timeout = Duration(
      seconds: ref.read(preferencesProvider).autoLockSeconds,
    );
    switch (state) {
      case AppLifecycleState.paused:
        _backgroundedAt = DateTime.now();
        if (timeout == Duration.zero) {
          ref.read(lockControllerProvider.notifier).lock();
        }
      case AppLifecycleState.resumed:
        final since = _backgroundedAt;
        _backgroundedAt = null;
        if (since != null && DateTime.now().difference(since) >= timeout) {
          ref.read(lockControllerProvider.notifier).lock();
        }
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(lockControllerProvider);
    return switch (status) {
      LockStatus.loading => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      LockStatus.needsSetup => const PinScreen(mode: PinScreenMode.setup),
      LockStatus.locked => const PinScreen(mode: PinScreenMode.unlock),
      LockStatus.unlocked => widget.child,
    };
  }
}
