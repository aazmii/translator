import 'package:flutter/material.dart' show WidgetsFlutterBinding, runApp;
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:hive/hive.dart' show Box;

import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:go_translator/src/core/di/providers.dart' show appBoxProvider;

import 'src/app.dart' show MyApp;
import 'src/core/db/hive.dart' show HiveDb;

void main() async {
  final appBox = await _init();

  runApp(ProviderScope(overrides: [appBoxProvider.overrideWithValue(appBox)], child: const MyApp()));
}

Future<Box<String>> _init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final appBox = await HiveDb.initialize();
  return appBox;
}

// void main() async => await _init().then((_) => runApp(const ProviderScope(child: MyApp())));

// Future<void> _init() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   await HiveDb.initialize();
// }
