import 'package:flutter/material.dart' show WidgetsFlutterBinding, runApp;
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;

import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:go_translator/src/core/di/providers.dart' show isarProvider;
import 'package:isar_community/isar.dart' show Isar;

import 'src/app.dart' show MyApp;
import 'src/core/db/isar.dart' show IsarDb;

void main() async {
  final isar = await _init();

  runApp(ProviderScope(overrides: [isarProvider.overrideWithValue(isar)], child: const MyApp()));
}

Future<Isar> _init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final isar = await IsarDb.initialize();
  return isar;
}

// void main() async => await _init().then((_) => runApp(const ProviderScope(child: MyApp())));

// Future<void> _init() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   await IsarDb.initialize();
// }
