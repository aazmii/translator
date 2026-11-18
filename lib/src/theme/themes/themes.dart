import 'package:flutter/material.dart';

// Shared parts of the light and dark themes, from design/DESIGN.md (Teal
// Meridian). Only colours differ between light and dark; type and shapes are
// the same in both.

/// The design's brand teal; the dark scheme's accents are generated from it so
/// both modes share one hue (design/DESIGN_DARK.md's cyan was not used).
const brandTeal = Color(0xFF00796B);

const fontFamily = 'Inter';

const inputDecorationTheme = InputDecorationTheme(
  border: InputBorder.none,
  focusedBorder: InputBorder.none,
  enabledBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
  fillColor: Colors.transparent,
  filled: true,
);

/// [size]/[lineHeight] in px, [tracking] in em, as in the design file.
TextStyle _style(double size, double lineHeight, FontWeight weight, [double tracking = 0]) => TextStyle(
  fontFamily: fontFamily,
  fontSize: size,
  height: lineHeight / size,
  fontWeight: weight,
  letterSpacing: tracking * size,
);

/// The design's type scale. Slots the design doesn't define (displaySmall,
/// titleSmall) keep Material's defaults, in Inter via [ThemeData.fontFamily].
final textTheme = TextTheme(
  displayLarge: _style(44, 52, FontWeight.w700, -0.02), // display-lg
  displayMedium: _style(32, 40, FontWeight.w700, -0.01), // display-lg-mobile
  headlineLarge: _style(28, 36, FontWeight.w600, -0.01),
  headlineMedium: _style(24, 32, FontWeight.w600),
  headlineSmall: _style(20, 28, FontWeight.w600),
  titleLarge: _style(18, 24, FontWeight.w600),
  titleMedium: _style(16, 22, FontWeight.w600, 0.01),
  bodyLarge: _style(18, 26, FontWeight.w400), // source and translation text
  bodyMedium: _style(15, 22, FontWeight.w400, 0.01),
  bodySmall: _style(13, 18, FontWeight.w400, 0.01),
  labelLarge: _style(14, 20, FontWeight.w600, 0.02),
  labelMedium: _style(12, 16, FontWeight.w600, 0.03),
  labelSmall: _style(11, 14, FontWeight.w500, 0.04),
);

/// Builds a theme from [colorScheme] with the design's type and shapes.
ThemeData buildTheme(ColorScheme colorScheme) {
  const pill = StadiumBorder();
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    visualDensity: VisualDensity.compact,
    fontFamily: fontFamily,
    textTheme: textTheme,
    inputDecorationTheme: inputDecorationTheme,
    // Standard cards: rounded-lg (16px).
    cardTheme: const CardThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)))),
    // Dialogs: rounded-xl (24px).
    dialogTheme: const DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)))),
    // Navigation drawer: 28px rounded right corners.
    drawerTheme: const DrawerThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(28))),
    ),
    // Buttons and chips: pills.
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: pill)),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(shape: pill)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: pill)),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: pill)),
    chipTheme: const ChipThemeData(shape: pill),
  );
}
