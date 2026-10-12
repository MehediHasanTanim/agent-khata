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

class KhataApp extends ConsumerStatefulWidget {
  const KhataApp({super.key, required this.flavor, this.homeBuilder});

  final Flavor flavor;

  /// Overrides the post-unlock screen (used by widget tests).
  final WidgetBuilder? homeBuilder;

  @override
  ConsumerState<KhataApp> createState() => _KhataAppState();
}

class _KhataAppState extends ConsumerState<KhataApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(secureScreenProvider)
          .set(secure: ref.read(preferencesProvider).secureScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(preferencesProvider, (prev, next) {
      if (prev?.secureScreen != next.secureScreen) {
        ref.read(secureScreenProvider).set(secure: next.secureScreen);
      }
    });
    final prefs = ref.watch(preferencesProvider);
    final onboarded = ref.watch(onboardingDoneProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: widget.flavor != Flavor.prod,
      locale: prefs.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildTheme(prefs.theme),
      builder: (context, child) {
        // The app's own text size setting multiplies the system font size.
        final mq = MediaQuery.of(context);
        final system = mq.textScaler.scale(1);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(system * prefs.textScale),
          ),
          child: child!,
        );
      },
      home: onboarded
          ? LockGate(
              child: Builder(
                builder: widget.homeBuilder ?? (_) => const AppShell(),
              ),
            )
          : const OnboardingFlow(),
    );
  }
}
