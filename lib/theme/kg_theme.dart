import 'package:flutter/material.dart';

/// Kindergarten theme palette – single source of truth for the whole app.
class KG {
  // ── Colours ──────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFFFF7043); // coral orange
  static const Color primaryLight = Color(0xFFFF8A65);
  static const Color primaryDark  = Color(0xFFE64A19);
  static const Color accent       = Color(0xFF66BB6A); // mint green
  static const Color accentPurple = Color(0xFFAB47BC); // lavender
  static const Color accentBlue   = Color(0xFF42A5F5); // sky blue
  static const Color accentGold   = Color(0xFFFFA726); // sunny yellow
  static const Color bg           = Color(0xFFFFF8F0); // warm cream
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color divider      = Color(0xFFFFCCBC);
  static const Color textDark     = Color(0xFF4E342E);
  static const Color textMuted    = Color(0xFF8D6E63);

  // Avatar palette (cycles by initial char)
  static const List<Color> avatarColors = [
    Color(0xFFEF9A9A), Color(0xFF80CBC4), Color(0xFFA5D6A7),
    Color(0xFF9FA8DA), Color(0xFFFFCC80), Color(0xFFF48FB1),
  ];

  static Color avatarFor(String name) =>
      avatarColors[name.isEmpty ? 0 : name.codeUnitAt(0) % avatarColors.length];

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: accent,
          surface: surface,
        ),
        scaffoldBackgroundColor: bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          prefixIconColor: primary,
          labelStyle: const TextStyle(color: textMuted),
          hintStyle: const TextStyle(color: textMuted),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primary,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: textDark,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
        ),
        dividerColor: divider,
        iconTheme: const IconThemeData(color: primary),
      );
}
