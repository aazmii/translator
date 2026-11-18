import 'package:flutter/material.dart';

import '../themes.dart';

/// Accents (primary, secondary, tertiary and their containers) are generated
/// from the light theme's teal, so both modes share one hue. Neutrals,
/// surfaces, outlines and error colours come from design/DESIGN_DARK.md.
final darkColorScheme = ColorScheme.fromSeed(seedColor: brandTeal, brightness: Brightness.dark).copyWith(
  surface: const Color(0xFF121414),
  onSurface: const Color(0xFFE2E2E2),
  surfaceDim: const Color(0xFF121414),
  surfaceBright: const Color(0xFF383939),
  surfaceContainerLowest: const Color(0xFF0D0F0F),
  surfaceContainerLow: const Color(0xFF1A1C1C),
  surfaceContainer: const Color(0xFF1E2020),
  surfaceContainerHigh: const Color(0xFF282A2A),
  surfaceContainerHighest: const Color(0xFF333535),
  onSurfaceVariant: const Color(0xFFBCC9CB),
  outline: const Color(0xFF869395),
  outlineVariant: const Color(0xFF3D494B),
  inverseSurface: const Color(0xFFE2E2E2),
  onInverseSurface: const Color(0xFF2F3131),
  error: const Color(0xFFFFB4AB),
  onError: const Color(0xFF690005),
  errorContainer: const Color(0xFF93000A),
  onErrorContainer: const Color(0xFFFFDAD6),
);

ThemeData get darkTheme => buildTheme(darkColorScheme);
