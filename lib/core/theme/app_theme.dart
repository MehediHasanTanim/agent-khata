import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../settings/app_preferences.dart';
import 'app_tokens.dart';

/// Fallbacks so Bangla glyphs render on devices lacking a default Bangla font.
const _fontFallback = ['NotoSansBengali', 'Noto Sans Bengali', 'Hind Siliguri'];

/// "Organic" palette from the Claude Design system: cream ground, terracotta
/// (money out / primary) and sage (money in), over-rounded shapes.
const _terracotta = Color(0xFFC67139);

ThemeData buildTheme(AppThemeChoice choice) {
  switch (choice) {
    case AppThemeChoice.light:
      return _build(
        const ColorScheme(
          brightness: Brightness.light,
          primary: _terracotta,
          onPrimary: Color(0xFF201E1D),
          primaryContainer: Color(0xFFFFC6A5),
          onPrimaryContainer: Color(0xFF402310),
          secondary: Color(0xFF728157),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFE1EECC),
          onSecondaryContainer: Color(0xFF272E1B),
          tertiary: Color(0xFF645C50),
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFFDCD3C4),
          onTertiaryContainer: Color(0xFF2E2B25),
          error: Color(0xFFB3261E),
          onError: Colors.white,
          surface: Color(0xFFF5EAD8),
          onSurface: Color(0xFF201E1D),
          onSurfaceVariant: Color(0xFF645C50),
          surfaceContainerLowest: Color(0xFFF9F4ED),
          surfaceContainerLow: Color(0xFFF9F4ED),
          surfaceContainer: Color(0xFFEBDDC5),
          surfaceContainerHigh: Color(0xFFEEE7DB),
          surfaceContainerHighest: Color(0xFFDCD3C4),
          outline: Color(0xFFA19786),
          outlineVariant: Color(0xFFDCD3C4),
        ),
        AppTokens.light,
      );
    case AppThemeChoice.dark:
      return _build(
        const ColorScheme(
          brightness: Brightness.dark,
          primary: _terracotta,
          onPrimary: Color(0xFF201E1D),
          primaryContainer: Color(0xFF6A3C1E),
          onPrimaryContainer: Color(0xFFFFE1D0),
          secondary: Color(0xFFAEBF92),
          onSecondary: Color(0xFF272E1B),
          secondaryContainer: Color(0xFF33402A),
          onSecondaryContainer: Color(0xFFE1EECC),
          tertiary: Color(0xFFC0B6A5),
          onTertiary: Color(0xFF2E2B25),
          tertiaryContainer: Color(0xFF4A4338),
          onTertiaryContainer: Color(0xFFF3E8D6),
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          surface: Color(0xFF1C1915),
          onSurface: Color(0xFFF3E8D6),
          onSurfaceVariant: Color(0xFFC0B6A5),
          surfaceContainerLowest: Color(0xFF1C1915),
          surfaceContainerLow: Color(0xFF2A251F),
          surfaceContainer: Color(0xFF2B2620),
          surfaceContainerHigh: Color(0xFF38322A),
          surfaceContainerHighest: Color(0xFF4A4338),
          outline: Color(0xFF8A8070),
          outlineVariant: Color(0xFF4A4338),
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
    fontFamily: 'Figtree',
    fontFamilyFallback: _fontFallback,
  );
  const minSize = Size(AppTokens.minTapTarget, 56);
  const pill = StadiumBorder();
  final label = base.textTheme.labelLarge?.copyWith(
    fontWeight: FontWeight.w800,
    fontSize: 16,
  );
  final dark = scheme.brightness == Brightness.dark;
  return base.copyWith(
    textTheme: _textTheme(base.textTheme),
    extensions: [tokens],
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontFamily: 'Caprasimo',
        fontFamilyFallback: _fontFallback,
        fontSize: 26,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: minSize,
        shape: pill,
        textStyle: label,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: minSize,
        shape: pill,
        textStyle: label,
        side: BorderSide(color: scheme.outline),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: minSize,
        shape: pill,
        textStyle: label,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainer,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    listTileTheme: ListTileThemeData(
      minTileHeight: 56,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: pill,
      side: BorderSide.none,
      backgroundColor: scheme.surfaceContainerHighest,
      selectedColor: dark ? scheme.primaryContainer : scheme.onSurface,
      labelStyle: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
      ),
      secondaryLabelStyle: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: dark ? scheme.onPrimaryContainer : scheme.surface,
      ),
      checkmarkColor: dark ? scheme.onPrimaryContainer : scheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primaryContainer,
      indicatorShape: pill,
      height: 72,
      labelTextStyle: WidgetStatePropertyAll(
        base.textTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: pill,
      backgroundColor: dark
          ? scheme.surfaceContainerHighest
          : const Color(0xFF2E2B25),
      contentTextStyle: base.textTheme.bodyLarge?.copyWith(
        color: const Color(0xFFF9F4ED),
        fontWeight: FontWeight.w700,
      ),
      actionTextColor: const Color(0xFFF6A06B),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? scheme.secondary
            : scheme.outlineVariant,
      ),
      thumbColor: const WidgetStatePropertyAll(Colors.white),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    // Round sand back button, as in the design.
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.surfaceContainerHighest,
        ),
        child: Icon(LucideIcons.chevronLeft, color: scheme.onSurface),
      ),
    ),
  );
}
