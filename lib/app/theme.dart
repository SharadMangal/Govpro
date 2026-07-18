import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary brand — dark teal (from Lovable reference)
  static const Color primaryTeal = Color(0xFF1A5C5E);
  static const Color primarySeedLight = Color(0xFF1A5C5E);
  static const Color primarySeedDark = Color(0xFF38BDF8);

  // Status Colors
  static const Color statusCompleted = Color(0xFF10B981); // Emerald 500
  static const Color statusInProgress = Color(0xFF1A5C5E); // Dark teal (matches reference)
  static const Color statusDelayed = Color(0xFFDC2626);    // Red 600

  // Warm Backgrounds (from Lovable reference)
  static const Color bgLight = Color(0xFFF5F0EB); // Warm cream
  static const Color bgDark = Color(0xFF0F172A); // Slate 900

  // Card & Surface
  static const Color cardBorder = Color(0xFFE8E0D8); // Warm beige border
  static const Color cardBorderRadius = Color(0x00000000); // placeholder
  static const double cardRadius = 24.0;

  // Bottom Nav
  static const Color navPillBg = Color(0xFFD4EAE7); // Light teal/mint pill
  static const Color navInactive = Color(0xFF64748B); // Slate 500

  // Notification Bell
  static const Color bellBg = Color(0xFFF0E8E0); // Warm beige
  static const Color bellRedDot = Color(0xFFDC2626);

  // Compare screen
  static const Color compareOrange = Color(0xFFE8A838); // Amber orange

  // Progress bar
  static const Color progressBarOrange = Color(0xFFF5A623);
  static const Color progressBarTrack = Color(0xFFE0D8D0); // Warm grey track

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.hankenGroteskTextTheme(),
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.light,
        surface: Colors.white,
        primary: primaryTeal,
        secondary: compareOrange,
        error: statusDelayed,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: cardBorder, width: 1.0),
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(color: primaryTeal),
        unselectedIconTheme: IconThemeData(color: navInactive),
        labelType: NavigationRailLabelType.all,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1A1A1A),
        unselectedItemColor: navInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: cardBorder,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.hankenGroteskTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.dark,
        surface: const Color(0xFF1E293B), // Slate 800
        primary: const Color(0xFF2563EB), // Primary Blue
        secondary: const Color(0xFF38BDF8), // Secondary Cyan
        tertiary: const Color(0xFF22C55E), // Tertiary Green
        error: statusDelayed,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B), // Slate 800
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF334155), width: 1.0), // Slate 700
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Color(0xFF1E293B),
        selectedIconTheme: IconThemeData(color: Color(0xFF38BDF8)),
        unselectedIconTheme: IconThemeData(color: Color(0xFF94A3B8)),
        labelType: NavigationRailLabelType.all,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E293B),
        selectedItemColor: Color(0xFF38BDF8),
        unselectedItemColor: Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  /// Returns the corresponding color for a given project status string
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return statusCompleted;
      case 'delayed':
        return statusDelayed;
      case 'in_progress':
      default:
        return statusInProgress;
    }
  }

  /// Returns the capitalized display text for project status
  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'delayed':
        return 'Delayed';
      case 'in_progress':
        return 'In Progress';
      default:
        return status;
    }
  }

  /// Returns the light background color for status badge pills
  static Color getStatusBadgeBg(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFFD1FAE5); // Emerald 100
      case 'delayed':
        return const Color(0xFFFEE2E2); // Red 100
      case 'in_progress':
        return const Color(0xFFE0F2F1); // Teal 50
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  /// Returns dot color for status badges
  static Color getStatusDotColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return statusCompleted;
      case 'delayed':
        return statusDelayed;
      case 'in_progress':
        return statusInProgress;
      default:
        return navInactive;
    }
  }
}
