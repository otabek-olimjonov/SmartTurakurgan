import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kColorPrimary,
      surface: kColorCream,
    ),
    scaffoldBackgroundColor: kColorCream,
    appBarTheme: const AppBarTheme(
      backgroundColor: kColorWhite,
      foregroundColor: kColorInk,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: kColorInk,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: kColorWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      shadowColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(
      color: kColorStone,
      thickness: 0.5,
      space: 0,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: kColorPrimary,
      unselectedLabelColor: kColorTextMuted,
      indicatorColor: kColorPrimary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      dividerColor: kColorStone,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kColorPrimary,
        foregroundColor: kColorWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        minimumSize: const Size.fromHeight(48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kColorPrimary,
        side: const BorderSide(color: kColorPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        minimumSize: const Size.fromHeight(48),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: kColorInk),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: kColorInk),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: kColorInk),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kColorInk),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kColorInk),
      bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: kColorInk),
      bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: kColorInk),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: kColorTextMuted),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: kColorTextMuted),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kColorWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kColorStone, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kColorStone, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kColorPrimary, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: kColorWhite,
      selectedColor: kColorPrimary.withValues(alpha: 0.1),
      side: const BorderSide(color: kColorStone, width: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: kColorInk),
    ),
  );
}
