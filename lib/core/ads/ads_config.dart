/// Which ad units the app talks to.
///
/// Google's published **test** units are used everywhere except a production
/// build that was explicitly given live unit IDs, so development and beta
/// builds can never serve (or click) real ads.
enum AdsMode { test, live }

class AdsConfig {
  const AdsConfig({
    required this.enabled,
    required this.mode,
    required this.bannerUnitId,
    required this.interstitialUnitId,
  });

  /// Google's demo units for adaptive banners and interstitials.
  static const testBannerUnitId = 'ca-app-pub-3940256099942544/9214589741';
  static const testInterstitialUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  static const _testPublisher = '3940256099942544';

  /// Nothing is shown and the SDK is never started.
  static const disabled = AdsConfig(
    enabled: false,
    mode: AdsMode.test,
    bannerUnitId: testBannerUnitId,
    interstitialUnitId: testInterstitialUnitId,
  );

  final bool enabled;
  final AdsMode mode;
  final String bannerUnitId;
  final String interstitialUnitId;

  /// Reads the build-time switches (`--dart-define`):
  /// `ADS_DISABLED`, `ADS_MODE` (`live` to opt in), `ADMOB_BANNER_ID`,
  /// `ADMOB_INTERSTITIAL_ID`.
  static AdsConfig fromEnvironment({required bool isDevFlavor}) => resolve(
    isDevFlavor: isDevFlavor,
    disabled: const bool.fromEnvironment('ADS_DISABLED'),
    modeName: const String.fromEnvironment('ADS_MODE', defaultValue: 'test'),
    liveBannerId: const String.fromEnvironment('ADMOB_BANNER_ID'),
    liveInterstitialId: const String.fromEnvironment('ADMOB_INTERSTITIAL_ID'),
  );

  /// Live units only when: not the dev flavor, mode is `live`, and both IDs
  /// look like real (non-Google-test) ad unit IDs. Anything else falls back
  /// to the test units.
  static AdsConfig resolve({
    required bool isDevFlavor,
    bool disabled = false,
    String modeName = 'test',
    String liveBannerId = '',
    String liveInterstitialId = '',
  }) {
    if (disabled) return AdsConfig.disabled;
    final wantsLive = !isDevFlavor && modeName == 'live';
    if (wantsLive &&
        _isLiveUnit(liveBannerId) &&
        _isLiveUnit(liveInterstitialId)) {
      return AdsConfig(
        enabled: true,
        mode: AdsMode.live,
        bannerUnitId: liveBannerId,
        interstitialUnitId: liveInterstitialId,
      );
    }
    return const AdsConfig(
      enabled: true,
      mode: AdsMode.test,
      bannerUnitId: testBannerUnitId,
      interstitialUnitId: testInterstitialUnitId,
    );
  }

  static bool _isLiveUnit(String id) =>
      RegExp(r'^ca-app-pub-\d{16}/\d{10}$').hasMatch(id) &&
      !id.contains(_testPublisher);
}
