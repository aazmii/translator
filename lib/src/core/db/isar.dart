import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:go_translator/src/modules/home/data/modles/translator.setting.dart';
import 'package:isar_community/isar.dart' show Isar;
import '../../modules/setting/data/model/setting.model.dart' show AppSettingSchema;
import '../utils/files/paths.dart' show appDir, initDir;

const _schema = [AppSettingSchema, TranslatorSettingSchema];

// void openDBSync(AppDir dir) => db = Isar.openSync(_schema, inspector: !kReleaseMode, directory: dir.db.path);

class IsarDb {
  static Future<Isar> initialize() async {
    await initDir();
    return await Isar.open(
      _schema,
      inspector: !kReleaseMode,
      directory: appDir.db.path,
    );
  }
}
