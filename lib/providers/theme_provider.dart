import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Manages light/dark mode, persisted in the Hive "settings" box
/// (opened in `main()` before the app starts).
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String boxName = 'settings';
  static const String _themeKey = 'theme_mode';

  final Box? _box;

  ThemeNotifier([this._box])
    : super(_box?.get(_themeKey) == 'dark' ? ThemeMode.dark : ThemeMode.light);

  void setDarkMode(bool dark) {
    state = dark ? ThemeMode.dark : ThemeMode.light;
    _box?.put(_themeKey, dark ? 'dark' : 'light');
  }

  void toggleTheme() => setDarkMode(state != ThemeMode.dark);

  bool get isDarkMode => state == ThemeMode.dark;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final box = Hive.isBoxOpen(ThemeNotifier.boxName)
      ? Hive.box(ThemeNotifier.boxName)
      : null;
  return ThemeNotifier(box);
});

// App theme definitions
class AppTheme {
  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.jostTextTheme(),
      primaryColor: Colors.black87,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: Colors.black87,
        secondary: Color(0xFF6C63FF),
        surface: Colors.white,
        error: Colors.red,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAFAFA),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: Colors.black87),

      // Divider theme
      dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.jostTextTheme(ThemeData.dark().textTheme),
      primaryColor: Colors.white,
      scaffoldBackgroundColor: const Color(0xFF121212),

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Color(0xFF6C63FF),
        surface: Color(0xFF1E1E1E),
        error: Colors.red,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
        ),
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: Colors.white),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2C2C2C),
        thickness: 1,
      ),
    );
  }

  // Get appropriate text color based on theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  // Get appropriate secondary text color
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
  }

  // Get appropriate background color
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF121212)
        : const Color(0xFFFAFAFA);
  }

  // Get appropriate card color
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  // Get appropriate border color
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2C)
        : Colors.grey.shade200;
  }
}
