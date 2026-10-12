import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../l10n/gen/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.appName, style: theme.textTheme.headlineMedium),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) => Text(
              snap.data == null
                  ? ''
                  : l10n.aboutVersion(
                      '${snap.data!.version}+${snap.data!.buildNumber}',
                    ),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.aboutDisclaimer, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text(l10n.aboutPrivacy, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
