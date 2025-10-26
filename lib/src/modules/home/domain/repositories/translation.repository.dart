import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:go_translator/src/modules/home/domain/entities/language.entity.dart';
 
abstract class OfflineTranslationRepository {
  Future<List<LanguageEntity>> getAvailableLanguages();
  Future<bool> downloadLanguage(String code);
  Future<bool> deleteLanguage(String code);
  Future<String?> translateText(OnDeviceTranslator translator, String text);
}
