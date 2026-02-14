import 'package:go_translator/src/modules/home/domain/entities/translation.model.dart';

abstract class TranslationRpository {
  Future<TranslationSettingEntity?> getTranslationSetting();

  Future saveTranslationSetting(TranslationSettingEntity tSetting);

  Future<String?> translateText({
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String text,
  });
}
