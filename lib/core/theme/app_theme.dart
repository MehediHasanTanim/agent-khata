import 'package:flutter/material.dart';

import '../settings/app_preferences.dart';
import 'app_tokens.dart';

/// Fallbacks so Bangla glyphs render on devices lacking a default Bangla font.
const _fontFallback = ['Noto Sans Bengali', 'Hind Siliguri'];

ThemeData buildTheme(AppThemeChoice choice) {
  switch (choice) {
    case AppThemeChoice.light:
      return _build(
        ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E4F)),
        AppTokens.light,
      );
    case AppThemeChoice.dark:
      return _build(
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B6E4F),
          brightness: Brightness.dark,
        ),
        AppTokens.dark,
      );
    case AppThemeChoice.highContrast:
      return _build(
        const ColorScheme.highContrastDark(
          primary: Color(0xFFFFFF00),
          onPrimary: Colors.black,
          secondary: Color(0xFF00E5FF),
          onSecondary: Colors.black,
          surface: Colors.black,
          onSurface: Colors.white,
          error: Color(0xFFFF6B6B),
          onError: Colors.black,
        ),
        AppTokens.highContrast,
      );
  }
}

/// Typography scale: larger than Material defaults for poor lighting and
/// quick glances at the counter.
TextTheme _textTheme(TextTheme base) => base.copyWith(
  displayLarge: base.displayLarge?.copyWith(fontSize: 48),
  displayMedium: base.displayMedium?.copyWith(fontSize: 40),
  headlineMedium: base.headlineMedium?.copyWith(fontSize: 28),
  titleLarge: base.titleLarge?.copyWith(fontSize: 22),
  titleMedium: base.titleMedium?.copyWith(fontSize: 18),
  bodyLarge: base.bodyLarge?.copyWith(fontSize: 18),
  bodyMedium: base.bodyMedium?.copyWith(fontSize: 16),
  labelLarge: base.labelLarge?.copyWith(fontSize: 16),
);

ThemeData _build(ColorScheme scheme, AppTokens tokens) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    fontFamilyFallback: _fontFallback,
  );
  const minSize = Size(AppTokens.minTapTarget, 56);
  return base.copyWith(
    textTheme: _textTheme(base.textTheme),
    extensions: [tokens],
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: minSize),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: minSize),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: minSize),
    ),
    listTileTheme: const ListTileThemeData(minTileHeight: 56),
  );
}
