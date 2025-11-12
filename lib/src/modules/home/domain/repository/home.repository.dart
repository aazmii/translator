import 'package:go_translator/src/modules/home/domain/entities/translator.setting.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

abstract class HomeRepository {
  Future<TranslatorSettingEntity?> getTranslationSetting();

  Future saveTranslationSetting(TranslatorSettingEntity tSetting);
  
  Future<String?> translateText(OnDeviceTranslator translator, String text);
}
