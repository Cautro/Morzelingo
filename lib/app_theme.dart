import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color accent = Color(0xFF4F7CFF);
  static const Color background = Color(0xFFF4F7FB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD14343);
  static const Color success = Color(0xFF1F9D63);
  static const Color warning = Color(0xFFD7A328);
  static const Color info = Color(0xFF2F7CF6);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFD7DFEA);

  static const Color Darkprimary = Color(0xFF6F9BFF);
  static const Color DarkprimaryDark = Color(0xFF4F7CFF);
  static const Color Darkaccent = Color(0xFF8DB2FF);
  static const Color Darkbackground = Color(0xFF09111F);
  static const Color Darkcard = Color(0xFF111C2E);
  static const Color Darkerror = Color(0xFFFF7B7B);
  static const Color Darksuccess = Color(0xFF4AD295);
  static const Color Darkwarning = Color(0xFFF4C65D);
  static const Color Darkinfo = Color(0xFF69A2FF);
  static const Color DarktextPrimary = Color(0xFFF5F8FF);
  static const Color DarktextSecondary = Color(0xFF9DAECC);
  static const Color Darkborder = Color(0xFF22324A);

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        scheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          secondary: accent,
          tertiary: info,
          error: error,
          surface: card,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimary,
          onError: Colors.white,
          outline: border,
          shadow: const Color(0x140F172A),
        ),
        scaffoldColor: background,
        cardColor: card,
        contentColor: textPrimary,
        secondaryTextColor: textSecondary,
        dividerColor: border,
      );

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        scheme: ColorScheme.fromSeed(
          seedColor: Darkprimary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: Darkprimary,
          secondary: Darkaccent,
          tertiary: Darkinfo,
          error: Darkerror,
          surface: Darkcard,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: DarktextPrimary,
          onError: Colors.white,
          outline: Darkborder,
          shadow: const Color(0x66000000),
        ),
        scaffoldColor: Darkbackground,
        cardColor: Darkcard,
        contentColor: DarktextPrimary,
        secondaryTextColor: DarktextSecondary,
        dividerColor: Darkborder,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffoldColor,
    required Color cardColor,
    required Color contentColor,
    required Color secondaryTextColor,
    required Color dividerColor,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldColor,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .copyWith(
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: contentColor,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: contentColor,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: contentColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: contentColor,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: contentColor,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );

    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: dividerColor),
    );

    return base.copyWith(
      textTheme: textTheme,
      dividerColor: dividerColor,
      cardColor: cardColor,
      shadowColor: scheme.shadow,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldColor,
        foregroundColor: contentColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: contentColor),
        actionsIconTheme: IconThemeData(color: contentColor),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        height: 74,
        elevation: 0,
        indicatorColor: scheme.primary.withOpacity(brightness == Brightness.dark ? 0.22 : 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : secondaryTextColor,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? scheme.primary : secondaryTextColor,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: dividerColor.withOpacity(brightness == Brightness.dark ? 0.9 : 0.75),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: dividerColor,
          disabledForegroundColor: secondaryTextColor,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: contentColor,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          side: BorderSide(color: dividerColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.titleMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            color: scheme.primary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? const Color(0xFFF8FAFC)
            : const Color(0xFF0D1728),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium,
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: contentColor),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return brightness == Brightness.light
              ? const Color(0xFFF8FAFC)
              : const Color(0xFFCCE0FF);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return dividerColor;
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(color: scheme.primary);
            }
            return BorderSide(color: dividerColor);
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primary.withOpacity(brightness == Brightness.dark ? 0.22 : 0.08);
            }
            return cardColor;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primary;
            }
            return secondaryTextColor;
          }),
          textStyle: WidgetStatePropertyAll(
            textTheme.titleMedium ?? const TextStyle(),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: brightness == Brightness.light
            ? const Color(0xFFE7EEF8)
            : const Color(0xFF162338),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        iconColor: scheme.primary,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.light
            ? const Color(0xFF10223B)
            : const Color(0xFFE8F0FF),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: brightness == Brightness.light ? Colors.white : Darkbackground,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
