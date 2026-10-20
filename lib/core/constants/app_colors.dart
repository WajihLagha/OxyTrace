import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static AppColorScheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  static const Color navy900 = Color(0xFF03045E);
  static const Color navy800 = Color(0xFF023E8A);
  static const Color blue700 = Color(0xFF0077B6);
  static const Color blue600 = Color(0xFF0096C7);
  static const Color blue500 = Color(0xFF00B4D8);
  static const Color sky400 = Color(0xFF48CAE4);
  static const Color sky300 = Color(0xFF90E0EF);
  static const Color sky200 = Color(0xFFADE8F4);
  static const Color sky100 = Color(0xFFCAF0F8);

  static const Color danger = Color(0xFFE24B4A);
  static const Color warning = Color(0xFFEF9F27);
  static const Color success = Color(0xFF1DB87A);
  static const Color info = blue600;

  // Legacy constants used by existing widgets.
  static const Color primary = blue600;
  static const Color primaryDark = blue700;
  static const Color primaryLight = blue500;
  static const Color accent = sky400;
  static const Color background = Color(0xFF080C1A);
  static const Color surface = Color(0xFF0D1526);
  static const Color surfaceVariant = Color(0xFF152035);
  static const Color onPrimary = Colors.white;
  static const Color onBackground = sky100;
  static const Color onSurface = sky200;
  static const Color muted = sky300;
  static const Color divider = Color(0xFF1A2E45);

  static const AppColorScheme dark = AppColorScheme(
    primary: blue600,
    primaryDark: blue700,
    primaryLight: blue500,
    accent: sky400,
    background: Color(0xFF080C1A),
    surface: Color(0xFF0D1526),
    surfaceVariant: Color(0xFF152035),
    onPrimary: Colors.white,
    onBackground: sky100,
    onSurface: sky200,
    muted: sky300,
    divider: Color(0xFF1A2E45),
  );

  static const AppColorScheme light = AppColorScheme(
    primary: navy800,
    primaryDark: navy900,
    primaryLight: blue700,
    accent: blue600,
    background: Color(0xFFF4FBFE),
    surface: Colors.white,
    surfaceVariant: Color(0xFFE4F5FB),
    onPrimary: Colors.white,
    onBackground: navy900,
    onSurface: Color(0xFF102A43),
    muted: Color(0xFF5B7C99),
    divider: Color(0xFFD5EAF2),
  );
}

@immutable
class AppColorScheme {
  const AppColorScheme({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.onPrimary,
    required this.onBackground,
    required this.onSurface,
    required this.muted,
    required this.divider,
  });

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color onPrimary;
  final Color onBackground;
  final Color onSurface;
  final Color muted;
  final Color divider;

  Color get danger => AppColors.danger;
  Color get warning => AppColors.warning;
  Color get success => AppColors.success;
  Color get info => AppColors.info;
}

class AppTheme {
  AppTheme._();

  static ThemeData buildTheme(Brightness brightness) {
    final s = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: s.primary,
      brightness: brightness,
    ).copyWith(
      primary: s.primary,
      onPrimary: s.onPrimary,
      primaryContainer: s.primaryDark,
      onPrimaryContainer: s.onPrimary,
      secondary: s.accent,
      onSecondary: s.onPrimary,
      secondaryContainer: s.surfaceVariant,
      onSecondaryContainer: s.onSurface,
      error: AppColors.danger,
      onError: Colors.white,
      surface: s.surface,
      onSurface: s.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: s.background,
      dividerColor: s.divider,
      primaryColor: s.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: s.background,
        foregroundColor: s.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: s.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: s.divider),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: s.surfaceVariant,
        hintStyle: TextStyle(color: s.muted),
        labelStyle: TextStyle(color: s.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: s.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: s.primary,
          foregroundColor: s.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: s.primary,
          side: BorderSide(color: s.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: s.primary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return s.primary;
          }
          return s.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return s.primary.withValues(alpha: 0.45);
          }
          return s.surfaceVariant;
        }),
      ),
    );
  }

  static ThemeData get darkTheme => buildTheme(Brightness.dark);
  static ThemeData get lightTheme => buildTheme(Brightness.light);
}
