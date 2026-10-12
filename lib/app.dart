import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap.dart';
import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/lock/lock_gate.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/shell/app_shell.dart';
import 'l10n/gen/app_localizations.dart';

class KhataApp extends ConsumerWidget {
  const KhataApp({super.key, required this.flavor, this.homeBuilder});

  final Flavor flavor;

  /// Overrides the post-unlock screen (used by widget tests).
  final WidgetBuilder? homeBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final onboarded = ref.watch(onboardingDoneProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: flavor == Flavor.prod ? false : true,
      locale: prefs.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildTheme(prefs.theme),
      home: onboarded
          ? LockGate(
              child: Builder(builder: homeBuilder ?? (_) => const AppShell()),
            )
          : const OnboardingFlow(),
    );
  }
}
