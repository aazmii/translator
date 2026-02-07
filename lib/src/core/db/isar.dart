import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:isar_community/isar.dart' show CollectionSchema, Isar;
import '../utils/files/paths.dart' show appDir, initDir;

// void openDBSync(AppDir dir) => db = Isar.openSync(_schema, inspector: !kReleaseMode, directory: dir.db.path);

class IsarDb {
  static Future<Isar> initialize(List<CollectionSchema<dynamic>> schemas) async {
    await initDir();
    return await Isar.open(
      schemas,
      inspector: !kReleaseMode,
      directory: appDir.db.path,
    );
  }
}
