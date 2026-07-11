import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const navy = Color(0xFF172033);
  static const ivory = Color(0xFFF7F3EA);
  static const sage = Color(0xFF789582);
  static const amber = Color(0xFFE7A93B);

  static ThemeData get light => _build(
    brightness: Brightness.light,
    scheme: const ColorScheme.light(
      primary: navy,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE4E9E3),
      onPrimaryContainer: navy,
      secondary: sage,
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFDDE8E0),
      onSecondaryContainer: Color(0xFF243A2D),
      tertiary: amber,
      onTertiary: Color(0xFF302000),
      tertiaryContainer: Color(0xFFFFE3AD),
      onTertiaryContainer: Color(0xFF4B3508),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      surface: ivory,
      onSurface: navy,
      surfaceContainerHighest: Color(0xFFECE8DE),
      outline: Color(0xFF777B75),
      outlineVariant: Color(0xFFD4D5CC),
    ),
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    scheme: const ColorScheme.dark(
      primary: Color(0xFFB9CBBE),
      onPrimary: Color(0xFF183126),
      primaryContainer: Color(0xFF31483B),
      onPrimaryContainer: Color(0xFFD5E8DA),
      secondary: Color(0xFFAFCDB9),
      onSecondary: Color(0xFF183527),
      secondaryContainer: Color(0xFF304D3B),
      onSecondaryContainer: Color(0xFFCBEAD4),
      tertiary: Color(0xFFFFC968),
      onTertiary: Color(0xFF432C00),
      tertiaryContainer: Color(0xFF604100),
      onTertiaryContainer: Color(0xFFFFDEA1),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      surface: Color(0xFF111722),
      onSurface: Color(0xFFE7E8EA),
      surfaceContainerHighest: Color(0xFF29303B),
      outline: Color(0xFF919A93),
      outlineVariant: Color(0xFF414942),
    ),
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF1A2230) : const Color(0xFFFFFDF8),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    );
  }
}
