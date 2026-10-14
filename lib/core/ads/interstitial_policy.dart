/// Where an interstitial may be shown. Only natural breaks, never a money
/// flow.
enum AdTrigger {
  /// The agent leaves the daily summary right after closing a day.
  daySummaryExit,

  /// A shift handover finished and the screen returned to Home.
  shiftHandover,
}

/// Persistent counters for the frequency rules.
abstract class InterstitialStore {
  int? get lastShownMs;
  set lastShownMs(int? value);

  /// Business-agnostic calendar day (`YYYY-MM-DD`, Dhaka) the count is for.
  String? get countDay;
  set countDay(String? value);

  int get countToday;
  set countToday(int value);
}

class MemoryInterstitialStore implements InterstitialStore {
  @override
  int? lastShownMs;
  @override
  String? countDay;
  @override
  int countToday = 0;
}

/// Frequency rules for interstitials:
///
/// * not within [warmup] of the session start,
/// * at least [minGap] since the last one,
/// * at most [dailyCap] per Dhaka calendar day.
class InterstitialPolicy {
  InterstitialPolicy({
    required this.store,
    DateTime Function()? clock,
    this.minGap = const Duration(minutes: 15),
    this.dailyCap = 3,
    this.warmup = const Duration(minutes: 3),
  }) : _clock = clock ?? DateTime.now {
    _sessionStart = _clock();
  }

  final InterstitialStore store;
  final Duration minGap;
  final int dailyCap;
  final Duration warmup;
  final DateTime Function() _clock;
  late DateTime _sessionStart;

  /// Call when the app comes back from the background for a new session.
  void startSession() => _sessionStart = _clock();

  static String _dayKey(DateTime t) {
    final d = t.toUtc().add(const Duration(hours: 6));
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  bool canShow() {
    final now = _clock();
    if (now.difference(_sessionStart) < warmup) return false;

    final last = store.lastShownMs;
    if (last != null) {
      final since = now.difference(
        DateTime.fromMillisecondsSinceEpoch(last, isUtc: true),
      );
      if (since < minGap) return false;
    }
    final today = _dayKey(now);
    final count = store.countDay == today ? store.countToday : 0;
    return count < dailyCap;
  }

  /// Records that an interstitial was shown.
  void recordShown() {
    final now = _clock();
    final today = _dayKey(now);
    store
      ..countToday = (store.countDay == today ? store.countToday : 0) + 1
      ..countDay = today
      ..lastShownMs = now.toUtc().millisecondsSinceEpoch;
  }
}
