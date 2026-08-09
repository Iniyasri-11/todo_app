import 'package:flutter/material.dart';

/// Centralized app theme for Phase 1.
///
/// This file sets up a Material 3 theme with a professional
/// purple / indigo primary color and a bright background.
class AppTheme {
  static const Color _bgColor = Color(0xFFEEF0FF);
  static const Color _cardColor = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF7C6CFF),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFEDE4FF),
      onPrimaryContainer: Color(0xFF2A0F65),
      secondary: Color(0xFF7EB9E4),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD9EEFF),
      onSecondaryContainer: Color(0xFF0D3B5D),
      tertiary: Color(0xFFF0C4D8),
      onTertiary: Color(0xFF4E2A43),
      tertiaryContainer: Color(0xFFFFE5F0),
      onTertiaryContainer: Color(0xFF501E3B),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1F2140),
      surfaceVariant: Color(0xFFE8E3F4),
      onSurfaceVariant: Color(0xFF6D6B83),
      background: Color(0xFFEEF0FF),
      onBackground: Color(0xFF1F2140),
      error: Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410004),
      outline: Color(0xFF9A95B8),
      shadow: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: Color(0xFF1F2140),
      inversePrimary: Color(0xFF625BFF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _bgColor,
      cardColor: _cardColor,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary.withOpacity(0.12),
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
        titleTextStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.5),
        bodyMedium: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F3FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        secondaryLabelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFFFFFFFF),
        elevation: 4,
        shadowColor: Color(0x26000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
      ),
    );
  }
}
