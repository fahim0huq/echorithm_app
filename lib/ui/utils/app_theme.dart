import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color accent = Color(0xFF3949AB);

  static const Color background = Color(0xFFF6F7FB);

  static const Color darkBackground = Color(0xFF121318);

  static const Color textGrey = Color(0xFF8A8FA3);

  static ThemeData get lightTheme => _buildTheme(Brightness.light, background);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark, darkBackground);

  static ThemeData _buildTheme(Brightness brightness, Color backgroundColor) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: accent,
      scaffoldBackgroundColor: backgroundColor,
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }

  static Color cardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E2129) : Colors.white;
  }
}
