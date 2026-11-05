import '../entities/language.dart';

abstract interface class OfflineLanguageRepository {
  Future<List<Language>> getAvailableLanguages();
  Future<bool> downloadLanguage(String code);
  Future<bool> deleteLanguage(String code);
}
