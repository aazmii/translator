import 'package:go_translator/src/core/domain/entities/language.entity.dart';

abstract class OfflineLanguageRepository {
  Future<List<LanguageEntity>> getAvailableLanguages();
  Future<bool> downloadLanguage(String code);
  Future<bool> deleteLanguage(String code);
}
