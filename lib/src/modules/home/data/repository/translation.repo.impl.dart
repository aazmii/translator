import 'package:hive/hive.dart' show Box;
import 'package:go_translator/src/core/db/hive.dart';
import 'package:go_translator/src/modules/home/data/modles/translator.setting.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation.model.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../domain/repository/home.repository.dart';

class TranslationRepositoryImpl implements TranslationRpository {
  final Box<String> box;
  TranslationRepositoryImpl(this.box);
  @override
  Future<String?> translateText({
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String text,
  }) async {
    final translator = OnDeviceTranslator(
      sourceLanguage: _languageFromCode(sourceLanguageCode),
      targetLanguage: _languageFromCode(targetLanguageCode),
    );
    try {
      return await translator.translateText(text);
    } finally {
      translator.close();
    }
  }

  @override
  Future<TranslationSettingEntity?> getTranslationSetting() async {
    final raw = box.get(HiveDb.translatorSettingKey);
    if (raw == null) return null;
    return TranslatorSetting.fromJson(raw).toDomain();
  }

  @override
  Future saveTranslationSetting(TranslationSettingEntity tSetting) async {
    await box.put(HiveDb.translatorSettingKey, TranslatorSetting.fromDomain(tSetting).toRawJson());
  }
}

TranslateLanguage _languageFromCode(String code) => TranslateLanguage.values.firstWhere(
      (e) => e.bcpCode == code,
      orElse: () => TranslateLanguage.english,
    );
