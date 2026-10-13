import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/security/pin_service.dart';
import '../../l10n/gen/app_localizations.dart';
import 'lock_controller.dart';
import 'pin_pad.dart';

enum PinScreenMode { setup, unlock }

/// Sets a new PIN (enter, then confirm) or unlocks with the existing one.
class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key, required this.mode});

  final PinScreenMode mode;

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _entered = '';
  String? _firstEntry;
  String? _error;
  Duration? _lockedFor;
  Timer? _ticker;
  bool _busy = false;

  bool _bioAvailable = false;
  String? _userId; // null = owner

  @override
  void initState() {
    super.initState();
    if (widget.mode == PinScreenMode.unlock) {
      _refreshLockout();
      Future.microtask(_initBiometric);
    }
  }

  Future<void> _initBiometric() async {
    if (!ref.read(preferencesProvider).biometricEnabled) return;
    // Biometrics open the owner's session, so they are off once staff exist.
    final staff = await ref.read(staffServiceProvider).activeStaff();
    if (staff.isNotEmpty || !mounted) return;
    final service = ref.read(biometricServiceProvider);
    if (!await service.isAvailable() || !mounted) return;
    setState(() => _bioAvailable = true);
    await _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    if (_lockedFor != null) return;
    final l10n = AppLocalizations.of(context);
    final ok = await ref
        .read(biometricServiceProvider)
        .authenticate(l10n.bioReason);
    if (ok && mounted) {
      ref.read(lockControllerProvider.notifier).unlockWithBiometric();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _refreshLockout() async {
    final remaining = await ref
        .read(lockControllerProvider.notifier)
        .lockoutRemaining();
    _applyLockout(remaining);
  }

  void _applyLockout(Duration? remaining) {
    _ticker?.cancel();
    if (!mounted) return;
    setState(() => _lockedFor = remaining);
    if (remaining == null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final left = _lockedFor;
      if (left == null) return;
      final next = left - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        _ticker?.cancel();
        if (mounted) setState(() => _lockedFor = null);
      } else {
        setState(() => _lockedFor = next);
      }
    });
  }

  void _onDigit(String d) {
    if (_entered.length >= PinService.maxLength) return;
    setState(() {
      _entered += d;
      _error = null;
    });
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _onSubmit() async {
    if (_busy || !PinService.isValidFormat(_entered)) return;
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(lockControllerProvider.notifier);
    setState(() => _busy = true);
    try {
      if (widget.mode == PinScreenMode.setup) {
        if (_firstEntry == null) {
          setState(() {
            _firstEntry = _entered;
            _entered = '';
          });
        } else if (_firstEntry == _entered) {
          await controller.setPin(_entered);
        } else {
          setState(() {
            _firstEntry = null;
            _entered = '';
            _error = l10n.pinMismatch;
          });
        }
        return;
      }
      final result = await controller.unlock(_entered, userId: _userId);
      if (!mounted) return;
      switch (result) {
        case PinVerified():
          break;
        case PinWrong(:final attemptsBeforeDelay, :final delay):
          setState(() {
            _entered = '';
            _error = delay > Duration.zero
                ? null
                : l10n.pinWrong(
                    ref
                        .read(preferencesProvider)
                        .digits
                        .localize('$attemptsBeforeDelay'),
                  );
          });
          if (delay > Duration.zero) _applyLockout(delay);
        case PinLockedOut(:final remaining):
          setState(() => _entered = '');
          _applyLockout(remaining);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(preferencesProvider);
    final digits = prefs.digits;
    final theme = Theme.of(context);

    final isSetup = widget.mode == PinScreenMode.setup;
    final confirming = isSetup && _firstEntry != null;
    final title = !isSetup
        ? l10n.pinUnlockTitle
        : (confirming ? l10n.pinConfirmTitle : l10n.pinSetupTitle);
    final subtitle = !isSetup
        ? l10n.pinUnlockSubtitle
        : (confirming ? l10n.pinConfirmSubtitle : l10n.pinSetupSubtitle);

    final staff = ref.watch(activeStaffProvider).value;
    final lockedFor = _lockedFor;
    final message = lockedFor != null
        ? l10n.pinLockedOut(digits.localize('${lockedFor.inSeconds + 1}'))
        : _error;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  if (!isSetup && (staff?.isNotEmpty ?? false)) ...[
                    Text(l10n.whoAreYou, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      children: [
                        ChoiceChip(
                          key: const ValueKey('user-owner'),
                          label: Text(l10n.roleOwner),
                          selected: _userId == null,
                          onSelected: (_) => setState(() {
                            _userId = null;
                            _entered = '';
                            _error = null;
                          }),
                        ),
                        for (final m in staff!)
                          ChoiceChip(
                            key: ValueKey('user-${m.id}'),
                            label: Text(m.name),
                            selected: _userId == m.id,
                            onSelected: (_) => setState(() {
                              _userId = m.id;
                              _entered = '';
                              _error = null;
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  PinDots(length: _entered.length),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: message == null
                        ? null
                        : Text(
                            message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                  ),
                  if (_bioAvailable)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextButton.icon(
                        key: const ValueKey('bio-unlock'),
                        icon: const Icon(Icons.fingerprint),
                        label: Text(l10n.bioUse),
                        onPressed: _tryBiometric,
                      ),
                    ),
                  PinPad(
                    digits: digits,
                    onDigit: _onDigit,
                    onDelete: _onDelete,
                    onSubmit: _onSubmit,
                    enabled: lockedFor == null && !_busy,
                    canSubmit: PinService.isValidFormat(_entered),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
