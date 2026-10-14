import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/bootstrap.dart';
import '../../core/db/db_settings.dart';
import '../../core/i18n/digit_formatter.dart';
import '../../core/providers.dart';
import '../../core/settings/app_preferences.dart';
import '../../core/widgets/khata_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../accounts/low_alerts_screen.dart';
import '../backup/backup_screen.dart';
import '../commission/commission_rates_screen.dart';
import '../debug/ledger_debug_screen.dart';
import '../diagnostics/diagnostics_screen.dart';
import '../expenses/recurring_screens.dart';
import '../lock/lock_controller.dart';
import '../staff/staff_screen.dart';
import 'about_screen.dart';
import 'categories_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(preferencesProvider);
    final controller = ref.read(preferencesProvider.notifier);
    final digits = prefs.digits;

    final session = ref.watch(sessionProvider);
    final isOwner = session?.isOwner ?? false;

    // Staff get only personal display options.
    final staffChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        child: Column(
          children: [
            _Section(
              title: l10n.language,
              children: [
                _Seg<String>(
                  label: l10n.language,
                  value: prefs.languageCode,
                  options: [
                    ('bn', l10n.languageBangla),
                    ('en', l10n.languageEnglish),
                  ],
                  onChanged: (v) =>
                      controller.update((p) => p.copyWith(languageCode: v)),
                ),
                _Seg<double>(
                  label: l10n.textSize,
                  value: prefs.textScale,
                  options: [
                    (1.0, l10n.textSizeNormal),
                    (1.15, l10n.textSizeLarge),
                    (1.3, l10n.textSizeXL),
                  ],
                  onChanged: (v) =>
                      controller.update((p) => p.copyWith(textScale: v)),
                ),
              ],
            ),
            _Section(
              title: l10n.settings,
              children: [
                _Nav(
                  icon: LucideIcons.lock,
                  label: l10n.switchUser,
                  value: session == null ? null : l10n.signedInAs(session.name),
                  onTap: () => ref.read(lockControllerProvider.notifier).lock(),
                ),
                _Nav(
                  icon: LucideIcons.info,
                  label: l10n.aboutTitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AboutScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: !isOwner
            ? staffChildren
            : [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  child: Column(
                    children: [
                      _Section(
                        title: l10n.language,
                        children: [
                          _Seg<String>(
                            label: l10n.language,
                            value: prefs.languageCode,
                            options: [
                              ('bn', l10n.languageBangla),
                              ('en', l10n.languageEnglish),
                            ],
                            onChanged: (v) => controller.update(
                              (p) => p.copyWith(languageCode: v),
                            ),
                          ),
                          _Seg<DigitStyle>(
                            label: l10n.digitStyle,
                            value: prefs.digitStyle,
                            options: [
                              (DigitStyle.bangla, l10n.digitsBangla),
                              (DigitStyle.latin, l10n.digitsLatin),
                            ],
                            onChanged: (v) => controller.update(
                              (p) => p.copyWith(digitStyle: v),
                            ),
                          ),
                          _Tog(
                            label: l10n.digitGrouping,
                            value: prefs.bangladeshiGrouping,
                            onChanged: (v) => controller.update(
                              (p) => p.copyWith(bangladeshiGrouping: v),
                            ),
                          ),
                          _Seg<AppThemeChoice>(
                            label: l10n.theme,
                            value: prefs.theme,
                            options: [
                              (AppThemeChoice.light, l10n.themeLight),
                              (AppThemeChoice.dark, l10n.themeDark),
                              (
                                AppThemeChoice.highContrast,
                                l10n.themeHighContrast,
                              ),
                            ],
                            onChanged: (v) =>
                                controller.update((p) => p.copyWith(theme: v)),
                          ),
                          _Seg<double>(
                            label: l10n.textSize,
                            value: prefs.textScale,
                            options: [
                              (1.0, l10n.textSizeNormal),
                              (1.15, l10n.textSizeLarge),
                              (1.3, l10n.textSizeXL),
                            ],
                            onChanged: (v) => controller.update(
                              (p) => p.copyWith(textScale: v),
                            ),
                          ),
                        ],
                      ),
                      _Section(
                        title: l10n.lockNow,
                        children: [
                          _Seg<int>(
                            label: l10n.autoLock,
                            value: prefs.autoLockSeconds,
                            options: [
                              (0, l10n.autoLockImmediately),
                              for (final s in const [30, 60, 300])
                                (
                                  s,
                                  l10n.autoLockSeconds(digits.localize('$s')),
                                ),
                            ],
                            onChanged: (v) => controller.update(
                              (p) => p.copyWith(autoLockSeconds: v),
                            ),
                          ),
                          _Tog(
                            label: l10n.bioToggle,
                            value: prefs.biometricEnabled,
                            onChanged: (v) async {
                              if (!v) {
                                await controller.update(
                                  (p) => p.copyWith(biometricEnabled: false),
                                );
                                return;
                              }
                              final service = ref.read(
                                biometricServiceProvider,
                              );
                              final messenger = ScaffoldMessenger.of(context);
                              if (!await service.isAvailable()) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text(l10n.bioUnavailable)),
                                );
                                return;
                              }
                              if (await service.authenticate(l10n.bioReason)) {
                                await controller.update(
                                  (p) => p.copyWith(biometricEnabled: true),
                                );
                              }
                            },
                          ),
                          _Tog(
                            label: l10n.secureToggle,
                            value: prefs.secureScreen,
                            onChanged: (v) => controller.update(
                              (p) => p.copyWith(secureScreen: v),
                            ),
                          ),
                          _Tog(
                            label: l10n.maskBalances,
                            value: prefs.maskBalances,
                            onChanged: (v) => controller.update(
                              (p) => p.copyWith(maskBalances: v),
                            ),
                          ),
                          _Nav(
                            icon: LucideIcons.lock,
                            label: l10n.lockNow,
                            onTap: () => ref
                                .read(lockControllerProvider.notifier)
                                .lock(),
                          ),
                        ],
                      ),
                      _Section(
                        title: l10n.shopName,
                        children: [
                          Consumer(
                            builder: (context, ref, _) {
                              final name =
                                  ref.watch(shopNameProvider).value ?? '';
                              return _Nav(
                                icon: LucideIcons.store,
                                label: l10n.shopName,
                                value: name.isEmpty ? l10n.shopNameNone : name,
                                onTap: () async {
                                  final c = TextEditingController(text: name);
                                  final value = await showDialog<String>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(l10n.shopName),
                                      content: TextField(
                                        controller: c,
                                        autofocus: true,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: Text(l10n.cancel),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, c.text.trim()),
                                          child: Text(l10n.save),
                                        ),
                                      ],
                                    ),
                                  );
                                  c.dispose();
                                  if (value != null) {
                                    await DbSettings(ref.read(databaseProvider))
                                        .set('shop_name', value);
                                    ref.invalidate(shopNameProvider);
                                  }
                                },
                              );
                            },
                          ),
                          Consumer(
                            builder: (context, ref, _) {
                              final hour =
                                  ref.watch(dayRolloverHourProvider).value ?? 4;
                              return _Seg<int>(
                                label: l10n.rolloverHour,
                                hint: l10n.rolloverHint,
                                value: hour,
                                options: [
                                  for (final h in const [0, 3, 4, 5])
                                    (
                                      h,
                                      '${digits.localize('$h')}:${digits.localize('00')}',
                                    ),
                                ],
                                onChanged: (v) async {
                                  await DbSettings(ref.read(databaseProvider))
                                      .set(DbSettings.dayRolloverHourKey, '$v');
                                  ref
                                    ..invalidate(dayRolloverHourProvider)
                                    ..invalidate(unclosedYesterdayProvider);
                                },
                              );
                            },
                          ),
                          _Seg<int>(
                            label: l10n.largeAmountWarning,
                            value: prefs.largeAmountTaka,
                            options: [
                              for (final t in const [10000, 50000, 100000])
                                (
                                  t,
                                  '৳ ${digits.localize(digits.group(t.toString()))}',
                                ),
                            ],
                            onChanged: (v) => controller.update(
                              (p) => p.copyWith(largeAmountTaka: v),
                            ),
                          ),
                          _Seg<int>(
                            label: l10n.settingsTolerance,
                            value: prefs.varianceToleranceTaka,
                            options: [
                              for (final t in const [0, 5, 10, 20])
                                (t, '৳ ${digits.localize('$t')}'),
                            ],
                            onChanged: (v) => controller.update(
                              (p) => p.copyWith(varianceToleranceTaka: v),
                            ),
                          ),
                          _Tog(
                            label: l10n.settingsReminder,
                            value: prefs.closeReminderEnabled,
                            onChanged: (v) => controller.update(
                              (p) => p.copyWith(closeReminderEnabled: v),
                            ),
                          ),
                          if (prefs.closeReminderEnabled)
                            _Seg<int>(
                              label: l10n.settingsReminderTime,
                              value: prefs.closeReminderHour,
                              options: [
                                for (final h in const [20, 21, 22, 23])
                                  (
                                    h,
                                    '${digits.localize('$h')}:${digits.localize('00')}',
                                  ),
                              ],
                              onChanged: (v) => controller.update(
                                (p) => p.copyWith(closeReminderHour: v),
                              ),
                            ),
                          _Nav(
                            icon: LucideIcons.tag,
                            label: l10n.categoriesTitle,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const CategoriesScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _Section(
                        title: l10n.aboutTitle,
                        children: [
                          _Tog(
                            label: l10n.rememberCustomers,
                            hint: l10n.rememberCustomersHint,
                            value: prefs.rememberCustomers,
                            onChanged: (v) => controller.update(
                              (p) => p.copyWith(rememberCustomers: v),
                            ),
                          ),
                          _Tog(
                            label: l10n.analyticsToggle,
                            hint: l10n.analyticsHint,
                            value: prefs.analyticsOptIn,
                            onChanged: (v) => controller.update(
                              (p) => p.copyWith(analyticsOptIn: v),
                            ),
                          ),
                        ],
                      ),
                      _Section(
                        title: l10n.settings,
                        children: [
                          _Nav(
                            icon: LucideIcons.bell,
                            label: l10n.lowTitle,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const LowAlertsScreen(),
                              ),
                            ),
                          ),
                          _Nav(
                            icon: LucideIcons.repeat,
                            label: l10n.recTitle,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const RecurringExpensesScreen(),
                              ),
                            ),
                          ),
                          _Nav(
                            icon: LucideIcons.users,
                            label: l10n.staffTitle,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const StaffScreen(),
                              ),
                            ),
                          ),
                          _Nav(
                            icon: LucideIcons.cloudUpload,
                            label: l10n.bkTitle,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const BackupScreen(),
                              ),
                            ),
                          ),
                          _Nav(
                            icon: LucideIcons.percent,
                            label: l10n.commissionRates,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const CommissionRatesScreen(),
                              ),
                            ),
                          ),
                          if (ref.watch(flavorProvider) == Flavor.dev)
                            _Nav(
                              icon: LucideIcons.bug,
                              label: 'Ledger debug harness (dev only)',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const LedgerDebugScreen(),
                                ),
                              ),
                            ),
                          _Nav(
                            icon: LucideIcons.info,
                            label: l10n.aboutTitle,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const AboutScreen(),
                              ),
                            ),
                          ),
                          _Nav(
                            icon: LucideIcons.gauge,
                            label: l10n.diagnostics,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const DiagnosticsScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
      ),
    );
  }
}

/// A rounded group of settings rows with a small terracotta caption.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            for (final c in children) ...[
              Divider(color: scheme.outlineVariant),
              c,
            ],
          ],
        ),
      ),
    );
  }
}

class _Seg<T> extends StatelessWidget {
  const _Seg({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final String? hint;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hint != null)
            Text(
              hint!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 8),
          PillSegmented<T>(
            options: options,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Tog extends StatelessWidget {
  const _Tog({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: hint == null ? null : Text(hint!),
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: value == null ? null : Text(value!),
      trailing: const Icon(LucideIcons.chevronRight),
      onTap: onTap,
    );
  }
}
