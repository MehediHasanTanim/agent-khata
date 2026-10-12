import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../i18n/digit_formatter.dart';

enum AppThemeChoice { light, dark, highContrast }

/// Non-sensitive user preferences. Secrets live in secure storage instead.
@immutable
class AppPreferences {
  const AppPreferences({
    this.languageCode = 'bn',
    this.digitStyle = DigitStyle.bangla,
    this.bangladeshiGrouping = true,
    this.theme = AppThemeChoice.light,
    this.autoLockSeconds = 30,
    this.maskBalances = false,
    this.largeAmountTaka = 50000,
    this.rememberCustomers = false,
    this.closeReminderEnabled = true,
    this.closeReminderHour = 21,
    this.varianceToleranceTaka = 0,
  });

  final String languageCode;
  final DigitStyle digitStyle;
  final bool bangladeshiGrouping;
  final AppThemeChoice theme;

  /// Seconds in the background before the app locks. 0 locks immediately.
  final int autoLockSeconds;

  /// Hide balances on home until the card is tapped.
  final bool maskBalances;

  /// Entries at or above this many taka ask for confirmation.
  final int largeAmountTaka;

  /// Opt-in: remember customer numbers/names and suggest them.
  final bool rememberCustomers;

  /// Daily local notification asking to close the day.
  final bool closeReminderEnabled;

  /// Hour (Dhaka, 0-23) of the reminder.
  final int closeReminderHour;

  /// Day-close differences up to this many taka are written off silently.
  final int varianceToleranceTaka;

  Locale get locale => Locale(languageCode);

  DigitFormatter get digits => DigitFormatter(
    style: digitStyle,
    bangladeshiGrouping: bangladeshiGrouping,
  );

  AppPreferences copyWith({
    String? languageCode,
    DigitStyle? digitStyle,
    bool? bangladeshiGrouping,
    AppThemeChoice? theme,
    int? autoLockSeconds,
    bool? maskBalances,
    int? largeAmountTaka,
    bool? rememberCustomers,
    bool? closeReminderEnabled,
    int? closeReminderHour,
    int? varianceToleranceTaka,
  }) => AppPreferences(
    languageCode: languageCode ?? this.languageCode,
    digitStyle: digitStyle ?? this.digitStyle,
    bangladeshiGrouping: bangladeshiGrouping ?? this.bangladeshiGrouping,
    theme: theme ?? this.theme,
    autoLockSeconds: autoLockSeconds ?? this.autoLockSeconds,
  );

  static const _kLang = 'pref_language';
  static const _kDigits = 'pref_digits';
  static const _kGrouping = 'pref_bd_grouping';
  static const _kTheme = 'pref_theme';
  static const _kAutoLock = 'pref_auto_lock_s';
  static const _kMask = 'pref_mask_balances';
  static const _kLarge = 'pref_large_amount';
  static const _kRemember = 'pref_remember_customers';
  static const _kReminder = 'pref_close_reminder';
  static const _kReminderHour = 'pref_close_reminder_hour';
  static const _kTolerance = 'pref_variance_tolerance';

  factory AppPreferences.load(SharedPreferences prefs) {
    const d = AppPreferences();
    final lang = prefs.getString(_kLang);
    return AppPreferences(
      languageCode: (lang == 'en' || lang == 'bn') ? lang! : d.languageCode,
      digitStyle:
          _byName(DigitStyle.values, prefs.getString(_kDigits)) ?? d.digitStyle,
      bangladeshiGrouping: prefs.getBool(_kGrouping) ?? d.bangladeshiGrouping,
      theme:
          _byName(AppThemeChoice.values, prefs.getString(_kTheme)) ?? d.theme,
      autoLockSeconds: prefs.getInt(_kAutoLock) ?? d.autoLockSeconds,
      maskBalances: prefs.getBool(_kMask) ?? d.maskBalances,
      largeAmountTaka: prefs.getInt(_kLarge) ?? d.largeAmountTaka,
      rememberCustomers: prefs.getBool(_kRemember) ?? d.rememberCustomers,
      closeReminderEnabled: prefs.getBool(_kReminder) ?? d.closeReminderEnabled,
      closeReminderHour: prefs.getInt(_kReminderHour) ?? d.closeReminderHour,
      varianceToleranceTaka:
          prefs.getInt(_kTolerance) ?? d.varianceToleranceTaka,
    );
  }

  Future<void> save(SharedPreferences prefs) async {
    await prefs.setString(_kLang, languageCode);
    await prefs.setString(_kDigits, digitStyle.name);
    await prefs.setBool(_kGrouping, bangladeshiGrouping);
    await prefs.setString(_kTheme, theme.name);
    await prefs.setInt(_kAutoLock, autoLockSeconds);
    await prefs.setBool(_kMask, maskBalances);
    await prefs.setInt(_kLarge, largeAmountTaka);
    await prefs.setBool(_kRemember, rememberCustomers);
    await prefs.setBool(_kReminder, closeReminderEnabled);
    await prefs.setInt(_kReminderHour, closeReminderHour);
    await prefs.setInt(_kTolerance, varianceToleranceTaka);
  }

  static T? _byName<T extends Enum>(List<T> values, String? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}
