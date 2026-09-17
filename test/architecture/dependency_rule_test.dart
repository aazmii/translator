import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final modules = Directory('lib/src/modules');

  test('every feature uses data, domain, and presentation layers', () {
    final features = modules
        .listSync()
        .whereType<Directory>()
        .map((directory) => directory.path)
        .toList();

    expect(features, isNotEmpty);
    for (final feature in features) {
      expect(Directory('$feature/data').existsSync(), isTrue, reason: feature);
      expect(
        Directory('$feature/domain').existsSync(),
        isTrue,
        reason: feature,
      );
      expect(
        Directory('$feature/presentation').existsSync(),
        isTrue,
        reason: feature,
      );
    }
  });

  test('domain layers depend only on domain and shared Dart code', () {
    for (final file in _dartFiles(modules, layer: 'domain')) {
      for (final import in _imports(file)) {
        expect(
          import,
          isNot(
            anyOf(
              contains('package:flutter'),
              contains('package:flutter_riverpod'),
              contains('package:hive'),
              contains('package:google_mlkit'),
              contains('/data/'),
              contains('/presentation/'),
            ),
          ),
          reason: '${file.path} imports $import',
        );
      }
    }
  });

  test('presentation layers do not import concrete data layers', () {
    for (final file in _dartFiles(modules, layer: 'presentation')) {
      for (final import in _imports(file)) {
        expect(
          import,
          isNot(contains('/data/')),
          reason: '${file.path} imports $import',
        );
      }
    }
  });

  test('data layers never depend on presentation', () {
    for (final file in _dartFiles(modules, layer: 'data')) {
      for (final import in _imports(file)) {
        expect(
          import,
          isNot(contains('/presentation/')),
          reason: '${file.path} imports $import',
        );
      }
    }
  });
}

Iterable<File> _dartFiles(Directory root, {required String layer}) {
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => file.path.split(Platform.pathSeparator).contains(layer));
}

Iterable<String> _imports(File file) sync* {
  final importPattern = RegExp("^import ['\"]([^'\"]+)['\"]", multiLine: true);
  for (final match in importPattern.allMatches(file.readAsStringSync())) {
    yield match.group(1)!;
  }
}
