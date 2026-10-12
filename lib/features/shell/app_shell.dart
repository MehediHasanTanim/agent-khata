import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../closeday/close_day_tab.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';

/// Bottom navigation: Home, History, Close day, Reports, Settings. Reports
/// is a placeholder until Phase 2.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_syncReminder);
  }

  /// Keeps the daily close-day notification in step with the settings.
  Future<void> _syncReminder() async {
    final prefs = ref.read(preferencesProvider);
    final service = ref.read(notificationServiceProvider);
    if (!prefs.closeReminderEnabled) {
      await service.cancelCloseReminder();
      return;
    }
    final l10n = lookupAppLocalizations(prefs.locale);
    await service.requestPermission();
    await service.scheduleCloseReminder(
      hour: prefs.closeReminderHour,
      title: l10n.notifCloseTitle,
      body: l10n.notifCloseBody,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(preferencesProvider, (prev, next) {
      if (prev == null ||
          prev.closeReminderEnabled != next.closeReminderEnabled ||
          prev.closeReminderHour != next.closeReminderHour ||
          prev.languageCode != next.languageCode) {
        _syncReminder();
      }
    });
    final l10n = AppLocalizations.of(context);
    final pages = <Widget>[
      const HomeScreen(),
      const HistoryScreen(),
      const CloseDayTab(),
      _Placeholder(title: l10n.navReports),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: l10n.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fact_check_outlined),
            selectedIcon: const Icon(Icons.fact_check),
            label: l10n.navCloseDay,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.navReports,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text(AppLocalizations.of(context).comingSoon)),
  );
}
