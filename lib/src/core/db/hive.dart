import 'package:hive_flutter/hive_flutter.dart';

import '../utils/files/paths.dart' show appDir, initDir;

class HiveDb {
  static const String boxName = 'app_box';
  static const String appSettingKey = 'app_setting';
  static const String translatorSettingKey = 'translator_setting';

  static Future<Box<String>> initialize() async {
    await initDir();
    await Hive.initFlutter(appDir.db.path);
    return Hive.openBox<String>(boxName);
  }
}
