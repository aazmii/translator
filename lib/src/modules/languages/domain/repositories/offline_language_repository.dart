import '../entities/language.dart';

abstract interface class OfflineLanguageRepository {
  Future<List<Language>> getAvailableLanguages();

  /// The language with this code and whether its model is downloaded, or
  /// null when the code is unknown.
  Future<Language?> getLanguage(String code);

  /// Downloads the model. With [wifiOnly] the download waits for Wi-Fi.
  Future<bool> downloadLanguage(String code, {bool wifiOnly = true});
  Future<bool> deleteLanguage(String code);
}
