import 'package:flutter/material.dart' show WidgetsFlutterBinding, runApp;
import 'package:flutter/foundation.dart' show LicenseEntryWithLineBreaks, LicenseRegistry;
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome, rootBundle;
import 'package:hive/hive.dart' show Box;

import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:go_translator/src/config/di/providers.dart' show appBoxProvider;

import 'src/app.dart' show MyApp;
import 'src/core/db/hive.dart' show HiveDb;

void main() async {
  final appBox = await _init();

  runApp(
    ProviderScope(
      overrides: [appBoxProvider.overrideWithValue(appBox)],
      child: const MyApp(),
    ),
  );
}

Future<Box<String>> _init() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicence();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final appBox = await HiveDb.initialize();
  return appBox;
}

/// Adds the bundled Inter font's SIL OFL licence to Flutter's licences page
/// (Settings > Open source licences). Packages register their own.
void _registerFontLicence() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/fonts/Inter-LICENSE.txt');
    yield LicenseEntryWithLineBreaks(const ['Inter (font)'], text);
  });
}

// void main() async => await _init().then((_) => runApp(const ProviderScope(child: MyApp())));

// Future<void> _init() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   await HiveDb.initialize();
// }
