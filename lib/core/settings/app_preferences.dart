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
  });

  final String languageCode;
  final DigitStyle digitStyle;
  final bool bangladeshiGrouping;
  final AppThemeChoice theme;

  /// Seconds in the background before the app locks. 0 locks immediately.
  final int autoLockSeconds;

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
    );
  }

  Future<void> save(SharedPreferences prefs) async {
    await prefs.setString(_kLang, languageCode);
    await prefs.setString(_kDigits, digitStyle.name);
    await prefs.setBool(_kGrouping, bangladeshiGrouping);
    await prefs.setString(_kTheme, theme.name);
    await prefs.setInt(_kAutoLock, autoLockSeconds);
  }

  static T? _byName<T extends Enum>(List<T> values, String? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}
