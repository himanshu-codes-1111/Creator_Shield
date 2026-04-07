import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.steelBlue,
        onPrimary: AppColors.white,
        secondary: AppColors.charcoal,
        onSecondary: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.charcoal,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.charcoalDark,
        ),
      ),
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme(Brightness.light),
      cardTheme: _cardTheme(Brightness.light),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
      chipTheme: _chipTheme,
    );
  }

  static ThemeData get dark {
    // Elegant Dark Theme Palette Mapping
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.steelBlueLight,
        onPrimary: AppColors.charcoal,
        secondary: AppColors.silver,
        onSecondary: AppColors.charcoalDark,
        error: AppColors.error,
        onError: AppColors.white,
        surface: AppColors.charcoalDark, // deeply dark surface
        onSurface: AppColors.cream,
      ),
      scaffoldBackgroundColor: AppColors.charcoal, // ink-black background
      fontFamily: GoogleFonts.dmSans().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.cream,
        ),
      ),
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
      cardTheme: _cardTheme(Brightness.dark),
      dividerTheme: DividerThemeData(
        color: AppColors.charcoalLight.withValues(alpha: 0.2),
        thickness: 1,
        space: 0,
      ),
      chipTheme: _chipTheme.copyWith(
        backgroundColor: AppColors.charcoalDark,
        side: BorderSide(color: AppColors.steelBlueLight.withValues(alpha: 0.3)),
        labelStyle: GoogleFonts.dmSans(color: AppColors.steelBlueLight, fontSize: 12),
      ),
    );
  }

  // Common styles
  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.steelBlue,
      foregroundColor: AppColors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  );

  static final _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.steelBlue,
      side: const BorderSide(color: AppColors.steelBlue, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  );

  static final _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.steelBlue,
      textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );

  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    var isDark = brightness == Brightness.dark;
    var fill = isDark ? AppColors.charcoalDark : AppColors.white;
    var borderSide = BorderSide(color: isDark ? AppColors.charcoalLight : AppColors.silver);
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: borderSide),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: borderSide),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.steelBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: GoogleFonts.dmSans(
        fontSize: 14, color: isDark ? AppColors.charcoalLight : AppColors.silverDark,
      ),
      labelStyle: GoogleFonts.dmSans(
        fontSize: 14, color: AppColors.charcoalLight,
      ),
    );
  }

  static CardThemeData _cardTheme(Brightness brightness) {
    var isDark = brightness == Brightness.dark;
    return CardThemeData(
      color: isDark ? AppColors.charcoalDark : AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: (isDark ? AppColors.charcoalLight.withValues(alpha: 0.2) : AppColors.silver.withValues(alpha: 0.5)),
        ),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static final _chipTheme = ChipThemeData(
    backgroundColor: AppColors.verifiedBg,
    labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.steelBlue),
    side: BorderSide(color: AppColors.steelBlue.withValues(alpha: 0.3)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
