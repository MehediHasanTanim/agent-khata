import 'package:flutter/material.dart';

/// Design tokens that Material's [ColorScheme] has no slot for.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.cashIn,
    required this.onCashIn,
    required this.cashOut,
    required this.onCashOut,
    required this.warning,
  });

  /// Money coming into the agent's cash drawer (always paired with an
  /// arrow-in icon and text; colour is never the only signal).
  final Color cashIn;
  final Color onCashIn;

  /// Money leaving the drawer.
  final Color cashOut;
  final Color onCashOut;

  final Color warning;

  /// Minimum interactive size (dp).
  static const double minTapTarget = 48;

  static const light = AppTokens(
    cashIn: Color(0xFF1B7F3B),
    onCashIn: Colors.white,
    cashOut: Color(0xFFC2410C),
    onCashOut: Colors.white,
    warning: Color(0xFFB45309),
  );

  static const dark = AppTokens(
    cashIn: Color(0xFF4ADE80),
    onCashIn: Color(0xFF003314),
    cashOut: Color(0xFFFB923C),
    onCashOut: Color(0xFF3B1500),
    warning: Color(0xFFFBBF24),
  );

  static const highContrast = AppTokens(
    cashIn: Color(0xFF00FF66),
    onCashIn: Colors.black,
    cashOut: Color(0xFFFFB300),
    onCashOut: Colors.black,
    warning: Color(0xFFFFFF00),
  );

  @override
  AppTokens copyWith({
    Color? cashIn,
    Color? onCashIn,
    Color? cashOut,
    Color? onCashOut,
    Color? warning,
  }) => AppTokens(
    cashIn: cashIn ?? this.cashIn,
    onCashIn: onCashIn ?? this.onCashIn,
    cashOut: cashOut ?? this.cashOut,
    onCashOut: onCashOut ?? this.onCashOut,
    warning: warning ?? this.warning,
  );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      cashIn: Color.lerp(cashIn, other.cashIn, t)!,
      onCashIn: Color.lerp(onCashIn, other.onCashIn, t)!,
      cashOut: Color.lerp(cashOut, other.cashOut, t)!,
      onCashOut: Color.lerp(onCashOut, other.onCashOut, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
