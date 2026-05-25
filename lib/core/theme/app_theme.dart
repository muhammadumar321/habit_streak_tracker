import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // StreakMaster Colors
  static const Color _deepNavy = Color(0xFF0F172A);
  static const Color _electricEmerald = Color(0xFF10B981);
  static const Color _softViolet = Color(0xFF8B5CF6);
  static const Color _surfaceDark = Color(0xFF1E293B);
  
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _deepNavy,
    primaryColor: _electricEmerald,
    colorScheme: const ColorScheme.dark(
      primary: _electricEmerald,
      secondary: _softViolet,
      surface: _surfaceDark,
      onSurface: Colors.white,
      background: _deepNavy,
      onBackground: Colors.white,
      tertiary: _softViolet,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: Colors.white, 
      displayColor: Colors.white,
      fontFamily: GoogleFonts.inter().fontFamily,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    // cardTheme removed to avoid type error
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _deepNavy.withOpacity(0.8),
      indicatorColor: _electricEmerald.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
      ),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: _electricEmerald);
        }
        return const IconThemeData(color: Colors.white54);
      }),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _electricEmerald,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );
  
  // We only support dark theme for StreakMaster
  static final lightTheme = darkTheme; 
}
