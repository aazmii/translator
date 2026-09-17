import 'package:hive/hive.dart';

import '../../../../core/db/hive.dart';
import '../models/translation_settings_model.dart';

abstract interface class TranslationLocalDataSource {
  Future<TranslationSettingsModel?> getSettings();
  Future<void> saveSettings(TranslationSettingsModel settings);
}

final class HiveTranslationLocalDataSource
    implements TranslationLocalDataSource {
  const HiveTranslationLocalDataSource(this._box);

  final Box<String> _box;

  @override
  Future<TranslationSettingsModel?> getSettings() async {
    final value = _box.get(HiveDb.translatorSettingKey);
    return value == null ? null : TranslationSettingsModel.fromJson(value);
  }

  @override
  Future<void> saveSettings(TranslationSettingsModel settings) {
    return _box.put(HiveDb.translatorSettingKey, settings.toJson());
  }
}
