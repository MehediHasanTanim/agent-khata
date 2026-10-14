import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/ads/ad_widgets.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/security/roles.dart';
import '../../l10n/gen/app_localizations.dart';
import '../closeday/close_day_tab.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../reports/reports_screen.dart';
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
    // Ads start after the first frame and only once the app is unlocked.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adsServiceProvider).initialize();
    });
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
    await _syncRecurring();
  }

  /// Notifies at 9:00 Dhaka time on the day each recurring expense is due.
  Future<void> _syncRecurring() async {
    final session = ref.read(sessionProvider);
    if (session == null || !session.isOwner) return;
    final prefs = ref.read(preferencesProvider);
    final service = ref.read(notificationServiceProvider);
    final l10n = lookupAppLocalizations(prefs.locale);
    final money = MoneyFormatter(digits: prefs.digits);
    final items =
        (await ref.read(recurringExpenseServiceProvider).watchAll().first)
            .where((r) => r.isActive)
            .take(20)
            .toList();
    for (var i = 0; i < 20; i++) {
      await service.cancel(3000 + i);
    }
    for (var i = 0; i < items.length; i++) {
      final r = items[i];
      final p = r.nextDueDate.split('-').map(int.parse).toList();
      // 09:00 in Dhaka (UTC+6) = 03:00 UTC on that date.
      await service.scheduleOnce(
        id: 3000 + i,
        at: DateTime.utc(p[0], p[1], p[2], 3),
        title: l10n.recNotifTitle,
        body: l10n.recNotifBody(r.categoryLabel ?? '', money.format(r.amount)),
      );
    }
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
    final session = ref.watch(sessionProvider);
    final showReports =
        session != null && Permissions.can(session, Permission.viewProfit);

    // (page, destination) pairs; Reports only for those who may see profit.
    final tabs = <(Widget, NavigationDestination)>[
      (
        const HomeScreen(),
        NavigationDestination(
          icon: const Icon(LucideIcons.house),
          selectedIcon: const Icon(LucideIcons.house),
          label: l10n.navHome,
        ),
      ),
      (
        const HistoryScreen(),
        NavigationDestination(
          icon: const Icon(LucideIcons.history),
          label: l10n.navHistory,
        ),
      ),
      (
        const CloseDayTab(),
        NavigationDestination(
          icon: const Icon(LucideIcons.clipboardCheck),
          selectedIcon: const Icon(LucideIcons.clipboardCheck),
          label: l10n.navCloseDay,
        ),
      ),
      if (showReports)
        (
          const ReportsScreen(),
          NavigationDestination(
            icon: const Icon(LucideIcons.chartColumn),
            selectedIcon: const Icon(LucideIcons.chartColumn),
            label: l10n.navReports,
          ),
        ),
      (
        const SettingsScreen(),
        NavigationDestination(
          icon: const Icon(LucideIcons.settings),
          selectedIcon: const Icon(LucideIcons.settings),
          label: l10n.navSettings,
        ),
      ),
    ];
    final index = _index.clamp(0, tabs.length - 1);

    return Scaffold(
      body: IndexedStack(index: index, children: [for (final t in tabs) t.$1]),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBanner(),
          NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [for (final t in tabs) t.$2],
          ),
        ],
      ),
    );
  }
}
