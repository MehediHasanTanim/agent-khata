/// Incremental lockout after failed PIN attempts.
///
/// The first [freeAttempts] failures carry no delay; after that the delay
/// grows: 30 s, 1 min, 5 min, then 15 min for every further failure.
class LockoutPolicy {
  const LockoutPolicy({this.freeAttempts = 4});

  final int freeAttempts;

  static const _steps = <Duration>[
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
  ];

  /// Delay to impose after [failedAttempts] consecutive failures.
  Duration delayFor(int failedAttempts) {
    if (failedAttempts <= freeAttempts) return Duration.zero;
    final step = failedAttempts - freeAttempts - 1;
    return _steps[step.clamp(0, _steps.length - 1)];
  }

  /// Failures remaining before the next delay kicks in.
  int attemptsBeforeDelay(int failedAttempts) =>
      (freeAttempts - failedAttempts).clamp(0, freeAttempts);
}
