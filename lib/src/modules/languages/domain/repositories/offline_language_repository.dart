import '../entities/language.dart';

abstract interface class OfflineLanguageRepository {
  Future<List<Language>> getAvailableLanguages();

  /// The language with this code and whether its model is downloaded, or
  /// null when the code is unknown.
  Future<Language?> getLanguage(String code);
  Future<bool> downloadLanguage(String code);
  Future<bool> deleteLanguage(String code);
}
