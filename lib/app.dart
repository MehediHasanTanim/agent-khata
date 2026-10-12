import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap.dart';
import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/lock/lock_gate.dart';
import 'l10n/gen/app_localizations.dart';

class KhataApp extends ConsumerWidget {
  const KhataApp({super.key, required this.flavor});

  final Flavor flavor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
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
      home: const LockGate(child: HomeScreen()),
    );
  }
}
