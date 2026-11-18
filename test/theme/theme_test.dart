import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/theme/themes/dark/dark.theme.dart';
import 'package:go_translator/src/theme/themes/light/light.theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('light theme uses the design colours and Inter', () {
    final theme = lightTheme;
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, const Color(0xFF005E53));
    expect(theme.colorScheme.surface, const Color(0xFFF5FAFA));
    expect(theme.textTheme.bodyLarge!.fontFamily, 'Inter');
    expect(theme.textTheme.bodyLarge!.fontSize, 18);
    expect(theme.textTheme.titleLarge!.fontSize, 18);
  });

  test('dark theme uses the dark design surfaces and Inter', () {
    final theme = darkTheme;
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.surface, const Color(0xFF121414));
    expect(theme.colorScheme.onSurface, const Color(0xFFE2E2E2));
    expect(theme.textTheme.bodyLarge!.fontFamily, 'Inter');
    expect(theme.textTheme.bodyLarge!.fontSize, 18);
  });

  test('dark accents share the light theme hue (teal, not cyan)', () {
    final lightHue = HSLColor.fromColor(lightColorScheme.primary).hue;
    final darkHue = HSLColor.fromColor(darkColorScheme.primary).hue;
    // ignore: avoid_print
    print('primary hue: light ${lightHue.round()}, dark ${darkHue.round()} (${darkColorScheme.primary})');
    expect((darkHue - lightHue).abs(), lessThan(10));
  });

  test('type and shapes are the same in both modes', () {
    // Colours differ by mode; font, size, weight, height and tracking must not.
    String type(TextStyle? s) => '${s!.fontFamily} ${s.fontSize} ${s.fontWeight} ${s.height} ${s.letterSpacing}';
    for (final slot in [(TextTheme t) => t.bodyLarge, (TextTheme t) => t.titleLarge, (TextTheme t) => t.labelLarge]) {
      expect(type(slot(darkTheme.textTheme)), type(slot(lightTheme.textTheme)));
    }
    expect(darkTheme.cardTheme.shape, lightTheme.cardTheme.shape);
    expect(darkTheme.dialogTheme.shape, lightTheme.dialogTheme.shape);
  });

  for (final (name, scheme) in [('light', lightColorScheme), ('dark', darkColorScheme)]) {
    test('$name text and buttons are readable (contrast >= 4.5)', () {
      final pairs = {
        'onSurface/surface': (scheme.onSurface, scheme.surface),
        'onSurface/surfaceContainerLow': (scheme.onSurface, scheme.surfaceContainerLow),
        'onSurfaceVariant/surface': (scheme.onSurfaceVariant, scheme.surface),
        'onPrimary/primary': (scheme.onPrimary, scheme.primary),
        'onPrimaryContainer/primaryContainer': (scheme.onPrimaryContainer, scheme.primaryContainer),
        'onSecondaryContainer/secondaryContainer': (scheme.onSecondaryContainer, scheme.secondaryContainer),
        'primary/surface': (scheme.primary, scheme.surface),
        'onError/error': (scheme.onError, scheme.error),
      };
      for (final MapEntry(key: pair, value: (fg, bg)) in pairs.entries) {
        expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: '$name $pair');
      }
    });
  }
}
