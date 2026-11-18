import 'package:flutter/material.dart';

/// The Go Translator mark: a teal rounded square with a white "translate"
/// glyph. Used in the app bar and the drawer header; the launcher icon is a
/// picture of the same mark (see tool/app_icon/).
///
/// `Icons.translate` on purpose, not `Icons.g_translate`: the latter is drawn
/// after Google Translate's logo (decision 2026-11-19).
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 40});

  /// Width and height of the square.
  final double size;

  /// Corner radius and glyph size as fractions of [size] (12px and 24px at 40).
  static const cornerRatio = 0.3;
  static const glyphRatio = 0.6;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Go Translator',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(size * cornerRatio),
        ),
        child: Icon(Icons.translate, size: size * glyphRatio, color: colors.onPrimary),
      ),
    );
  }
}
