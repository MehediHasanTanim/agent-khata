import 'package:agentkhata/core/ads/ads_config.dart';
import 'package:agentkhata/core/ads/interstitial_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const liveBanner = 'ca-app-pub-1234567890123456/1234567890';
  const liveInter = 'ca-app-pub-1234567890123456/0987654321';

  group('AdsConfig.resolve', () {
    test('production with live mode and real IDs uses the live units', () {
      final c = AdsConfig.resolve(
        isDevFlavor: false,
        modeName: 'live',
        liveBannerId: liveBanner,
        liveInterstitialId: liveInter,
      );
      expect(c.mode, AdsMode.live);
      expect(c.bannerUnitId, liveBanner);
      expect(c.interstitialUnitId, liveInter);
      expect(c.enabled, isTrue);
    });

    test('the dev flavor can never resolve live units', () {
      final c = AdsConfig.resolve(
        isDevFlavor: true,
        modeName: 'live',
        liveBannerId: liveBanner,
        liveInterstitialId: liveInter,
      );
      expect(c.mode, AdsMode.test);
      expect(c.bannerUnitId, AdsConfig.testBannerUnitId);
    });

    test('anything but explicit live mode stays on test units', () {
      for (final mode in ['', 'test', 'LIVE', 'beta']) {
        final c = AdsConfig.resolve(
          isDevFlavor: false,
          modeName: mode,
          liveBannerId: liveBanner,
          liveInterstitialId: liveInter,
        );
        expect(c.mode, AdsMode.test, reason: mode);
      }
    });

    test('missing, malformed or Google-test IDs fall back to test units', () {
      for (final (b, i) in [
        ('', ''),
        (liveBanner, ''),
        ('not-an-id', liveInter),
        (AdsConfig.testBannerUnitId, liveInter),
        (liveBanner, AdsConfig.testInterstitialUnitId),
      ]) {
        final c = AdsConfig.resolve(
          isDevFlavor: false,
          modeName: 'live',
          liveBannerId: b,
          liveInterstitialId: i,
        );
        expect(c.mode, AdsMode.test, reason: '$b / $i');
      }
    });

    test('the kill switch disables ads entirely', () {
      final c = AdsConfig.resolve(
        isDevFlavor: false,
        disabled: true,
        modeName: 'live',
        liveBannerId: liveBanner,
        liveInterstitialId: liveInter,
      );
      expect(c.enabled, isFalse);
    });
  });

  group('InterstitialPolicy', () {
    var now = DateTime.utc(2026, 10, 20, 4); // 10:00 Dhaka
    late MemoryInterstitialStore store;
    late InterstitialPolicy policy;

    setUp(() {
      now = DateTime.utc(2026, 10, 20, 4);
      store = MemoryInterstitialStore();
      policy = InterstitialPolicy(store: store, clock: () => now);
    });

    test('not during the warm-up period of a session', () {
      expect(policy.canShow(), isFalse);
      now = now.add(const Duration(minutes: 2, seconds: 59));
      expect(policy.canShow(), isFalse);
      now = now.add(const Duration(seconds: 2));
      expect(policy.canShow(), isTrue);
    });

    test('at least 15 minutes between interstitials', () {
      now = now.add(const Duration(minutes: 5));
      expect(policy.canShow(), isTrue);
      policy.recordShown();
      expect(policy.canShow(), isFalse);
      now = now.add(const Duration(minutes: 14, seconds: 59));
      expect(policy.canShow(), isFalse);
      now = now.add(const Duration(seconds: 2));
      expect(policy.canShow(), isTrue);
    });

    test('at most three per Dhaka day, then it resets the next day', () {
      now = now.add(const Duration(minutes: 5));
      for (var i = 0; i < 3; i++) {
        expect(policy.canShow(), isTrue, reason: 'show #${i + 1}');
        policy.recordShown();
        now = now.add(const Duration(minutes: 16));
      }
      expect(policy.canShow(), isFalse);
      expect(store.countToday, 3);

      // Next Dhaka day (after 18:00 UTC).
      now = DateTime.utc(2026, 10, 20, 18, 30);
      expect(policy.canShow(), isTrue);
      policy.recordShown();
      expect(store.countToday, 1);
    });

    test('state persists through the store across sessions', () {
      now = now.add(const Duration(minutes: 5));
      policy.recordShown();
      final second = InterstitialPolicy(store: store, clock: () => now);
      now = now.add(const Duration(minutes: 4)); // past warm-up, inside gap
      expect(second.canShow(), isFalse);
      now = now.add(const Duration(minutes: 12));
      expect(second.canShow(), isTrue);
    });

    test('a new session restarts the warm-up', () {
      now = now.add(const Duration(minutes: 30));
      expect(policy.canShow(), isTrue);
      policy.startSession();
      expect(policy.canShow(), isFalse);
    });
  });
}
