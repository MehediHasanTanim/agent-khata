import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../providers.dart';

/// A banner for the bottom of a screen. Collapses while the keyboard is open
/// and when ads are off. Only ever place it on screens that have no money
/// input (see docs/plan/admob-integration-plan.md section 4); the blocked
/// screens are checked by `test/core/ads/ad_placement_test.dart`.
class AdBanner extends ConsumerWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(adsServiceProvider);
    if (!ads.isEnabled) return const SizedBox.shrink();
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    // Rebuild when the SDK becomes ready; also nudge a (throttled) start in
    // case the first attempt could not finish, e.g. no network yet.
    return ValueListenableBuilder<bool>(
      valueListenable: ads.ready,
      builder: (context, isReady, _) {
        if (!isReady) {
          Future.microtask(ads.initialize);
          return const SizedBox.shrink();
        }
        return Semantics(
          container: true,
          label: l10n.adLabel,
          child: Container(
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.surface,
            child: ads.buildBanner(context),
          ),
        );
      },
    );
  }
}

/// `bottomNavigationBar` value for pushed screens that may show a banner.
class AdFooter extends StatelessWidget {
  const AdFooter({super.key});

  @override
  Widget build(BuildContext context) =>
      const SafeArea(top: false, child: AdBanner());
}
