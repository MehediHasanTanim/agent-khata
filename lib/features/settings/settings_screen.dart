import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../core/providers.dart';
import '../../core/settings/app_preferences.dart';
import '../../l10n/gen/app_localizations.dart';
import '../diagnostics/diagnostics_screen.dart';
import '../lock/lock_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(preferencesProvider);
    final controller = ref.read(preferencesProvider.notifier);
    final digits = prefs.digits;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          _Header(l10n.language),
          RadioGroup<String>(
            groupValue: prefs.languageCode,
            onChanged: (v) => controller.update(
              (p) => p.copyWith(languageCode: v ?? p.languageCode),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'bn',
                  title: Text(l10n.languageBangla),
                ),
                RadioListTile<String>(
                  value: 'en',
                  title: Text(l10n.languageEnglish),
                ),
              ],
            ),
          ),
          _Header(l10n.digitStyle),
          RadioGroup<DigitStyle>(
            groupValue: prefs.digitStyle,
            onChanged: (v) => controller.update(
              (p) => p.copyWith(digitStyle: v ?? p.digitStyle),
            ),
            child: Column(
              children: [
                RadioListTile<DigitStyle>(
                  value: DigitStyle.bangla,
                  title: Text(l10n.digitsBangla),
                ),
                RadioListTile<DigitStyle>(
                  value: DigitStyle.latin,
                  title: Text(l10n.digitsLatin),
                ),
              ],
            ),
          ),
          SwitchListTile(
            value: prefs.bangladeshiGrouping,
            title: Text(l10n.digitGrouping),
            onChanged: (v) =>
                controller.update((p) => p.copyWith(bangladeshiGrouping: v)),
          ),
          _Header(l10n.theme),
          RadioGroup<AppThemeChoice>(
            groupValue: prefs.theme,
            onChanged: (v) =>
                controller.update((p) => p.copyWith(theme: v ?? p.theme)),
            child: Column(
              children: [
                RadioListTile<AppThemeChoice>(
                  value: AppThemeChoice.light,
                  title: Text(l10n.themeLight),
                ),
                RadioListTile<AppThemeChoice>(
                  value: AppThemeChoice.dark,
                  title: Text(l10n.themeDark),
                ),
                RadioListTile<AppThemeChoice>(
                  value: AppThemeChoice.highContrast,
                  title: Text(l10n.themeHighContrast),
                ),
              ],
            ),
          ),
          _Header(l10n.autoLock),
          RadioGroup<int>(
            groupValue: prefs.autoLockSeconds,
            onChanged: (v) => controller.update(
              (p) => p.copyWith(autoLockSeconds: v ?? p.autoLockSeconds),
            ),
            child: Column(
              children: [
                RadioListTile<int>(
                  value: 0,
                  title: Text(l10n.autoLockImmediately),
                ),
                for (final s in const [30, 60, 300])
                  RadioListTile<int>(
                    value: s,
                    title: Text(l10n.autoLockSeconds(digits.localize('$s'))),
                  ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.lockNow),
            onTap: () {
              Navigator.of(context).popUntil((r) => r.isFirst);
              ref.read(lockControllerProvider.notifier).lock();
            },
          ),
          ListTile(
            leading: const Icon(Icons.speed_outlined),
            title: Text(l10n.diagnostics),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DiagnosticsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}
