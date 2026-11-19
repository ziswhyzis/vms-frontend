import 'package:flutter/material.dart';

/// Palette sampled from the Stark Group launch artwork:
/// deep navy base, cyan infrastructure accent, lime "active" signal.
class StarkColors {
  const StarkColors._();

  static const Color navy = Color(0xFF00081C);
  static const Color navySoft = Color(0xFF00102E);
  static const Color navyLift = Color(0xFF0B1C3A);
  static const Color cyan = Color(0xFF00B8F0);
  static const Color cyanDeep = Color(0xFF00779C);
  static const Color lime = Color(0xFF66D93F);
  static const Color amber = Color(0xFFF2A93B);
  static const Color red = Color(0xFFFF4D5E);

  static const Color canvas = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color ink = Color(0xFF0E1B2C);
  static const Color inkMuted = Color(0xFF5B6B80);
  static const Color line = Color(0xFFDCE3EC);
}

ThemeData buildStarkTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: StarkColors.cyan,
    brightness: Brightness.light,
  ).copyWith(
    primary: StarkColors.cyanDeep,
    onPrimary: Colors.white,
    secondary: const Color(0xFF3C8F26),
    onSecondary: Colors.white,
    error: StarkColors.red,
    surface: StarkColors.surface,
    onSurface: StarkColors.ink,
  );

  const TextStyle titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: StarkColors.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: StarkColors.canvas,
    fontFamily: 'Roboto',
    visualDensity: VisualDensity.standard,
    dividerTheme: const DividerThemeData(color: StarkColors.line, thickness: 1, space: 1),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: StarkColors.ink,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      headlineSmall: titleStyle,
      titleLarge: titleStyle,
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: StarkColors.ink,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: StarkColors.ink, height: 1.4),
      bodySmall: TextStyle(fontSize: 12, color: StarkColors.inkMuted, height: 1.4),
      labelLarge: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: StarkColors.inkMuted,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(fontSize: 13, color: StarkColors.inkMuted),
      labelStyle: const TextStyle(fontSize: 13, color: StarkColors.inkMuted),
      floatingLabelStyle: const TextStyle(fontSize: 13, color: StarkColors.cyanDeep, fontWeight: FontWeight.w600),
      errorStyle: const TextStyle(fontSize: 12, color: StarkColors.red, height: 1.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: StarkColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: StarkColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: StarkColors.cyan, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: StarkColors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: StarkColors.red, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: StarkColors.cyanDeep,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: StarkColors.ink,
        minimumSize: const Size(0, 46),
        side: const BorderSide(color: StarkColors.line),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: StarkColors.cyanDeep,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: StarkColors.inkMuted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titleTextStyle: titleStyle,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: StarkColors.navy,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    tooltipTheme: const TooltipThemeData(
      waitDuration: Duration(milliseconds: 400),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: StarkColors.line),
        ),
      ),
    ),
  );
}
