import 'package:flutter/material.dart';

/// Warm workbench palette.
/// Cream is the shell, sage is a quiet fill, muted teal is the action color,
/// and dusty rose marks anything destructive.
class StarkColors {
  const StarkColors._();

  static const Color cream = Color(0xFFF3E9DC);
  static const Color sage = Color(0xFF9CAF88);
  static const Color teal = Color(0xFF4F7C82);
  static const Color rose = Color(0xFFC08081);

  static const Color canvas = cream;
  static const Color surface = Color(0xFFFCF8EE);
  static const Color ink = Color(0xFF244043);
  static const Color inkMuted = Color(0xFF52675F);
  static const Color line = Color(0xFFCFD2B8);
  static const Color lattice = Color(0xFFE7E2D6);

  /// Same hues, darkened only where small text has to sit on cream.
  static const Color tealInk = Color(0xFF3E656A);
  static const Color roseInk = Color(0xFF8E4F51);
  static const Color sageInk = Color(0xFF4A603E);

  static const Color cyan = teal;
  static const Color cyanDeep = tealInk;
  static const Color red = roseInk;
  static const Color navy = ink;
  static const Color navySoft = tealInk;
  static const Color lime = sage;
}

/// VS Code modern-layout cards: 1px frame, tight radius, no drop shadow.
class StarkChrome {
  const StarkChrome._();

  static const double radius = 8;
  static const double gutter = 8;
  static const double margin = 12;

  static BoxDecoration card({Color color = StarkColors.surface}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: StarkColors.line),
    );
  }
}

ThemeData buildStarkTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: StarkColors.teal,
    brightness: Brightness.light,
  ).copyWith(
    primary: StarkColors.teal,
    onPrimary: Colors.white,
    secondary: StarkColors.sage,
    onSecondary: StarkColors.ink,
    error: StarkColors.roseInk,
    surface: StarkColors.surface,
    onSurface: StarkColors.ink,
  );

  const TextStyle titleStyle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: StarkColors.ink,
  );

  final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(StarkChrome.radius));

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: 'Nunito',
    visualDensity: VisualDensity.standard,
    dividerTheme: const DividerThemeData(color: StarkColors.line, thickness: 1, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: StarkColors.teal),
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
        fontFamily: 'Nunito',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: StarkColors.ink,
      ),
      bodyMedium: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: StarkColors.ink, height: 1.45),
      bodySmall: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: StarkColors.inkMuted, height: 1.45),
      labelLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: StarkColors.inkMuted,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: StarkColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: StarkColors.inkMuted),
      labelStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: StarkColors.inkMuted),
      floatingLabelStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 13,
        color: StarkColors.tealInk,
        fontWeight: FontWeight.w600,
      ),
      errorStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: StarkColors.roseInk, height: 1.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StarkChrome.radius),
        borderSide: const BorderSide(color: StarkColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StarkChrome.radius),
        borderSide: const BorderSide(color: StarkColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StarkChrome.radius),
        borderSide: const BorderSide(color: StarkColors.teal, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StarkChrome.radius),
        borderSide: const BorderSide(color: StarkColors.rose),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StarkChrome.radius),
        borderSide: const BorderSide(color: StarkColors.roseInk, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: StarkColors.teal,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: rounded,
        textStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: StarkColors.ink,
        minimumSize: const Size(0, 44),
        side: const BorderSide(color: StarkColors.line),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: rounded,
        textStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: StarkColors.tealInk,
        textStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: StarkColors.inkMuted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: StarkColors.surface,
      surfaceTintColor: StarkColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(StarkChrome.radius)),
      titleTextStyle: titleStyle,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: StarkColors.ink,
      contentTextStyle: const TextStyle(fontFamily: 'Nunito', color: StarkColors.cream, fontSize: 13),
      shape: rounded,
    ),
    tooltipTheme: const TooltipThemeData(
      waitDuration: Duration(milliseconds: 400),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StarkColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StarkChrome.radius),
          borderSide: const BorderSide(color: StarkColors.line),
        ),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(StarkColors.sage.withValues(alpha: 0.18)),
      dividerThickness: 1,
    ),
  );
}
