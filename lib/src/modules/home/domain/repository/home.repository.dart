import 'package:go_translator/src/modules/home/domain/entities/translation.model.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

abstract class TranslationRpository {
  Future<TranslationSettingEntity?> getTranslationSetting();

  Future saveTranslationSetting(TranslationSettingEntity tSetting);
  
  Future<String?> translateText(OnDeviceTranslator translator, String text);
}
