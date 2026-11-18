import 'package:flutter/widgets.dart'
    show BuildContext, FadeTransition, Navigator, PageRouteBuilder, Widget;

PageRouteBuilder<T> _fadeRoute<T>(Widget page, Duration duration) =>
    PageRouteBuilder<T>(
      transitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );

Future<T?> fadePush<T>(
  BuildContext context,
  Widget page, {
  Duration duration = const Duration(milliseconds: 150),
}) =>
    Navigator.push<T>(context, _fadeRoute<T>(page, duration));

/// Like [fadePush], but [page] replaces the current page, so Back from it
/// returns to the page underneath.
Future<T?> fadeReplace<T>(
  BuildContext context,
  Widget page, {
  Duration duration = const Duration(milliseconds: 150),
}) =>
    Navigator.pushReplacement<T, void>(context, _fadeRoute<T>(page, duration));
