import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Font families bundled in `assets/fonts/`.
abstract final class AppFonts {
  static const latin = 'Manrope';
  static const arabic = 'IBMPlexSansArabic';
  static const fallback = [arabic];
}

/// Text style helper. Manrope ships as a variable font, so the weight is set
/// both as [FontWeight] and as the `wght` axis, which every renderer honours.
/// [wght] sets an in-between axis value (e.g. 550) when a design needs it.
TextStyle appText({
  required double size,
  required FontWeight weight,
  double? wght,
  Color? color,
  double? height,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: AppFonts.latin,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: size,
    fontWeight: weight,
    fontVariations: [FontVariation.weight(wght ?? weight.value.toDouble())],
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors c) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: Palette.moss,
          brightness: brightness,
        ).copyWith(
          primary: c.primary,
          onPrimary: c.onPrimary,
          surface: c.background,
          onSurface: c.textPrimary,
          onSurfaceVariant: c.textSecondary,
          outline: c.line,
          error: c.danger,
        );

    TextStyle t(double size, FontWeight w, {double? height, Color? color}) =>
        appText(
          size: size,
          weight: w,
          height: height,
          color: color ?? c.textPrimary,
        );

    final textTheme = TextTheme(
      displaySmall: t(31, FontWeight.w800, height: 1.15),
      headlineMedium: t(28, FontWeight.w800, height: 1.2),
      headlineSmall: t(24, FontWeight.w800, height: 1.2),
      titleLarge: t(20, FontWeight.w700, height: 1.3),
      titleMedium: t(17, FontWeight.w700, height: 1.35),
      bodyLarge: t(16, FontWeight.w500, height: 1.45),
      bodyMedium: t(15, FontWeight.w500, height: 1.45, color: c.textSecondary),
      labelLarge: t(16, FontWeight.w700),
      labelMedium: t(14, FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      fontFamily: AppFonts.latin,
      fontFamilyFallback: AppFonts.fallback,
      textTheme: textTheme,
      extensions: [c],
    );
  }
}
