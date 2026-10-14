import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the ad placement rules of docs/plan/admob-integration-plan.md:
/// screens with money input, PIN entry or counting must never build an ad.
void main() {
  final root = Platform.environment['KHATA_ROOT'] ?? '.';

  // Screens that must stay free of any ad widget or ad trigger.
  const blocked = [
    'lib/features/entry/entry_screen.dart',
    'lib/features/entry/bulk_flexiload_screen.dart',
    'lib/features/entry/amount_keypad.dart',
    'lib/features/accounts/adjustment_screen.dart',
    'lib/features/dues/due_form_screen.dart',
    'lib/features/lock/pin_screen.dart',
    'lib/features/lock/pin_pad.dart',
    'lib/features/lock/lock_gate.dart',
    'lib/features/onboarding/onboarding_flow.dart',
    'lib/features/closeday/close_day_screen.dart',
    'lib/features/closeday/close_day_widgets.dart',
    'lib/features/shifts/shift_handover_screen.dart',
    'lib/features/backup/restore_flow.dart',
    'lib/features/staff/staff_service.dart',
  ];

  // Markers of ad code. (`interstitialOnExit` is a plain flag passed to the
  // summary screen, not an ad call.)
  const markers = [
    'AdBanner',
    'AdFooter',
    'adsServiceProvider',
    'maybeShowInterstitial',
    'AdMobAdsService',
    'google_mobile_ads',
  ];

  for (final path in blocked) {
    test('$path has no ads', () {
      final file = File('$root/$path');
      expect(file.existsSync(), isTrue, reason: 'missing $path');
      final text = file.readAsStringSync();
      for (final m in markers) {
        expect(text.contains(m), isFalse, reason: '$path mentions $m');
      }
    });
  }

  test('the SDK is imported by exactly one file', () {
    final hits = <String>[];
    for (final e in Directory('$root/lib').listSync(recursive: true)) {
      if (e is File && e.path.endsWith('.dart')) {
        if (e.readAsStringSync().contains('package:google_mobile_ads')) {
          hits.add(e.path.split('/lib/').last);
        }
      }
    }
    expect(hits, ['core/ads/admob_ads_service.dart']);
  });

  test(
    'the manifest removes advertising ID and personalization permissions',
    () {
      final manifest = File('$root/android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      for (final permission in [
        'com.google.android.gms.permission.AD_ID',
        'android.permission.ACCESS_ADSERVICES_AD_ID',
        'android.permission.ACCESS_ADSERVICES_ATTRIBUTION',
        'android.permission.ACCESS_ADSERVICES_TOPICS',
      ]) {
        expect(
          manifest,
          contains('$permission" tools:node="remove"'),
          reason: permission,
        );
      }
    },
  );
}
