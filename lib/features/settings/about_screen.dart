import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/ads/ad_widgets.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ads = ref.watch(adsServiceProvider);
    return Scaffold(
      bottomNavigationBar: const AdFooter(),
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondaryContainer,
              ),
              child: Icon(
                LucideIcons.bookOpen,
                size: 44,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.appName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: 'Caprasimo',
              fontWeight: FontWeight.w400,
            ),
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) => Text(
              snap.data == null
                  ? ''
                  : l10n.aboutVersion(
                      '${snap.data!.version}+${snap.data!.buildNumber}',
                    ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.aboutDisclaimer, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text(l10n.aboutPrivacy, style: theme.textTheme.bodyLarge),
          if (ads.isEnabled) ...[
            const SizedBox(height: 16),
            Text(l10n.aboutAds, style: theme.textTheme.bodyLarge),
            FutureBuilder<bool>(
              future: ads.privacyOptionsRequired(),
              builder: (context, snap) => snap.data == true
                  ? Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        key: const ValueKey('ad-privacy-options'),
                        onPressed: ads.showPrivacyOptions,
                        child: Text(l10n.adPrivacyOptions),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }
}
