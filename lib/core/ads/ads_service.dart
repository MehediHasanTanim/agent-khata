import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'interstitial_policy.dart';

/// The only way the rest of the app touches ads. Keeping the SDK behind this
/// interface lets tests and ad-free builds run without the plugin.
abstract class AdsService {
  /// Ads are switched on in this build.
  bool get isEnabled;

  /// Flips to true once the SDK is started and banners can load. Widgets
  /// listen to this so a banner appears as soon as the SDK is ready.
  ValueListenable<bool> get ready;

  /// Short human-readable state for the Diagnostics screen.
  String get status;

  /// Runs consent (where required) and starts the SDK. Safe to call more
  /// than once; never throws.
  Future<void> initialize();

  /// A banner, or an empty widget while there is nothing to show.
  Widget buildBanner(BuildContext context);

  /// Shows an interstitial if the frequency rules and readiness allow it.
  /// Completes when the ad closes, or immediately when nothing is shown.
  Future<void> maybeShowInterstitial(AdTrigger trigger);

  /// Whether Google's privacy options form must be offered in Settings.
  Future<bool> privacyOptionsRequired();

  Future<void> showPrivacyOptions();
}

class NoopAdsService implements AdsService {
  const NoopAdsService();

  static final ValueNotifier<bool> _never = ValueNotifier<bool>(false);

  @override
  bool get isEnabled => false;

  @override
  ValueListenable<bool> get ready => _never;

  @override
  String get status => 'ads off';

  @override
  Future<void> initialize() async {}

  @override
  Widget buildBanner(BuildContext context) => const SizedBox.shrink();

  @override
  Future<void> maybeShowInterstitial(AdTrigger trigger) async {}

  @override
  Future<bool> privacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptions() async {}
}
