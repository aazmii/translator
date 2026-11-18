// Renders the launcher icon pictures from the AppMark widget, so the home
// screen icon always matches the mark in the app bar and drawer.
//
// Run from the project root:
//   flutter test tool/app_icon/generate_app_icon_test.dart
//   dart run flutter_launcher_icons
//
// Writes (1024 x 1024):
//   assets/icons/app_icon.png             the whole mark (legacy icon, Android < 8)
//   assets/icons/app_icon_foreground.png  the white glyph only, sized for the
//                                         adaptive icon's safe zone; the teal
//                                         background is adaptive_icon_background
//                                         in pubspec.yaml (#005E53, light primary)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/core/widgets/app_mark.dart';
import 'package:go_translator/src/theme/themes/light/light.theme.dart';

const _size = 1024.0;

/// An adaptive icon shows about 72 of its 108dp canvas, so the glyph is sized
/// to the same share of that visible area as in AppMark (and stays well inside
/// the 66dp safe zone).
const _foregroundGlyph = _size * (72 / 108) * AppMark.glyphRatio;

Future<void> _loadMaterialIcons() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) throw StateError('FLUTTER_ROOT is not set; run with `flutter test`.');
  final font = File('$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf');
  final loader = FontLoader('MaterialIcons')..addFont(font.readAsBytes().then((b) => ByteData.sublistView(b)));
  await loader.load();
}

Future<void> _render(WidgetTester tester, Widget picture, String path) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: lightColorScheme),
      home: Center(
        child: RepaintBoundary(
          key: key,
          child: SizedBox.square(dimension: _size, child: picture),
        ),
      ),
    ),
  );
  await tester.pump();
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  // Real async work (encoding, file I/O) only completes inside runAsync.
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(path).writeAsBytes(data!.buffer.asUint8List(), flush: true);
  });
}

void main() {
  testWidgets('generate the launcher icon pictures', (tester) async {
    tester.view.physicalSize = const Size(_size, _size);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(_loadMaterialIcons);

    await _render(tester, const AppMark(size: _size), 'assets/icons/app_icon.png');
    await _render(
      tester,
      const Center(child: Icon(Icons.translate, size: _foregroundGlyph, color: Colors.white)),
      'assets/icons/app_icon_foreground.png',
    );
  });
}
