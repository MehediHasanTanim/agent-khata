import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_config.dart';
import 'ads_service.dart';
import 'interstitial_policy.dart';

/// Google AdMob implementation. This is the only file that imports the SDK.
///
/// Every request is non-personalized and capped at content rating G. No
/// business data, keywords or user identifiers are ever attached.
class AdMobAdsService implements AdsService {
  AdMobAdsService({
    required this.config,
    required this.policy,
    required this.canShowNow,
  });

  final AdsConfig config;
  final InterstitialPolicy policy;

  /// False while the app is locked or signed out.
  final bool Function() canShowNow;

  static const AdRequest _request = AdRequest(nonPersonalizedAds: true);

  bool _started = false;
  bool _ready = false;
  InterstitialAd? _interstitial;
  bool _showing = false;
  DateTime? _lastAttempt;
  String _status = 'not started';
  final ValueNotifier<bool> _readyNotifier = ValueNotifier<bool>(false);

  @override
  bool get isEnabled => config.enabled;

  @override
  ValueListenable<bool> get ready => _readyNotifier;

  @override
  String get status =>
      '${config.mode.name} units, $_status'
      '${_interstitial != null ? ', interstitial loaded' : ''}';

  @override
  Future<void> initialize() async {
    if (!config.enabled || _started || _ready) return;
    // Callers may ask often (every banner build); try at most every 30 s.
    final now = DateTime.now();
    if (_lastAttempt != null &&
        now.difference(_lastAttempt!) < const Duration(seconds: 30)) {
      return;
    }
    _lastAttempt = now;
    _started = true;
    _status = 'starting';
    try {
      await _gatherConsent().timeout(const Duration(seconds: 15));
      if (!await ConsentInformation.instance.canRequestAds()) {
        _status = 'waiting for consent info (offline?)';
        _started = false; // try again on the next opportunity
        return;
      }
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(maxAdContentRating: MaxAdContentRating.g),
      );
      await MobileAds.instance.initialize();
      _ready = true;
      _status = 'sdk ready';
      _readyNotifier.value = true;
      _loadInterstitial();
    } on Object catch (e) {
      _status = 'init failed: $e';
      debugPrint('Ads init failed: $e');
      _started = false;
    }
  }

  Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        // Shows Google's form only where the law requires it.
        await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
        if (!done.isCompleted) done.complete();
      },
      (_) {
        if (!done.isCompleted) done.complete(); // offline: use cached state
      },
    );
    return done.future;
  }

  @override
  Widget buildBanner(BuildContext context) {
    if (!config.enabled || !_ready) return const SizedBox.shrink();
    return _BannerView(unitId: config.bannerUnitId, request: _request);
  }

  void _loadInterstitial() {
    if (!_ready || _interstitial != null) return;
    InterstitialAd.load(
      adUnitId: config.interstitialUnitId,
      request: _request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (e) {
          _interstitial = null;
          debugPrint('Interstitial failed to load: $e');
        },
      ),
    );
  }

  @override
  Future<void> maybeShowInterstitial(AdTrigger trigger) async {
    if (!config.enabled || !_ready || _showing) return;
    if (!canShowNow() || !policy.canShow()) return;
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return; // never wait for an ad
    }
    _interstitial = null;
    _showing = true;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        if (!closed.isCompleted) closed.complete();
      },
    );
    policy.recordShown();
    try {
      await ad.show();
      await closed.future;
    } on Object {
      // A failed ad never blocks the flow.
    } finally {
      _showing = false;
      _loadInterstitial();
    }
  }

  @override
  Future<bool> privacyOptionsRequired() async {
    if (!config.enabled) return false;
    try {
      return await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((_) {});
    } on Object {
      // best effort
    }
  }
}

/// An anchored adaptive banner that collapses when it cannot load and
/// retries with backoff.
class _BannerView extends StatefulWidget {
  const _BannerView({required this.unitId, required this.request});

  final String unitId;
  final AdRequest request;

  @override
  State<_BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends State<_BannerView> {
  static const double _reserved = 50;

  BannerAd? _ad;
  AdSize? _size;
  bool _loaded = false;
  bool _failed = false;
  int _attempt = 0;
  Timer? _retry;
  double? _width;

  @override
  void dispose() {
    _retry?.cancel();
    unawaited(_ad?.dispose());
    super.dispose();
  }

  Future<void> _load(double width) async {
    _width = width;
    final size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
          Orientation.portrait,
          width.truncate(),
        );
    if (!mounted || size == null) return;
    await _ad?.dispose();
    setState(() {
      _size = size;
      _loaded = false;
      _failed = false;
    });
    final ad = BannerAd(
      adUnitId: widget.unitId,
      size: size,
      request: widget.request,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          _attempt = 0;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed to load: $error');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _ad = null;
            _loaded = false;
            _failed = true;
          });
          final seconds = (60 * (1 << _attempt.clamp(0, 3))).clamp(60, 480);
          _attempt++;
          _retry?.cancel();
          _retry = Timer(Duration(seconds: seconds), () {
            if (mounted && _width != null) _load(_width!);
          });
        },
      ),
    );
    _ad = ad;
    unawaited(ad.load());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (_ad == null && !_failed && _width == null && width > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _load(width));
        }
        if (_failed) return const SizedBox.shrink();
        if (_loaded && _ad != null && _size != null) {
          return SizedBox(
            width: width,
            height: _size!.height.toDouble(),
            child: AdWidget(ad: _ad!),
          );
        }
        // While loading, hold the space so the layout does not jump.
        return const SizedBox(height: _reserved);
      },
    );
  }
}
