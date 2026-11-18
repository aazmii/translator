import 'package:flutter/material.dart';

/// The rounded surface of the source and translation cards (28px, from the
/// Stitch translator screen). Light mode uses a soft teal shadow; dark mode a
/// thin outline instead, as design/DESIGN_DARK.md asks.
class CardSurface extends StatelessWidget {
  const CardSurface({super.key, required this.color, required this.child});

  final Color color;
  final Widget child;

  static const radius = 28.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final light = Theme.of(context).brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: light ? null : Border.all(color: scheme.outlineVariant),
        boxShadow: light
            ? const [
                BoxShadow(color: Color(0x14004D40), blurRadius: 16, spreadRadius: -2, offset: Offset(0, 4)),
                BoxShadow(color: Color(0x0A004D40), blurRadius: 4, offset: Offset(0, 1)),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: child,
    );
  }
}
