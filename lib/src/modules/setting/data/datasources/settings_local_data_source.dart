import 'package:hive/hive.dart';

import '../../../../core/db/hive.dart';
import '../models/settings_model.dart';

abstract interface class SettingsLocalDataSource {
  Future<SettingsModel?> getSettings();
  Future<void> saveSettings(SettingsModel settings);
}

final class HiveSettingsLocalDataSource implements SettingsLocalDataSource {
  const HiveSettingsLocalDataSource(this._box);

  final Box<String> _box;

  @override
  Future<SettingsModel?> getSettings() async {
    final value = _box.get(HiveDb.appSettingKey);
    return value == null ? null : SettingsModel.fromJson(value);
  }

  @override
  Future<void> saveSettings(SettingsModel settings) {
    return _box.put(HiveDb.appSettingKey, settings.toJson());
  }
}
