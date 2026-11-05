import '../entities/translation_settings.dart';

abstract interface class TranslationRepository {
  Future<TranslationSettings?> getSettings();
  Future<void> saveSettings(TranslationSettings settings);
  Future<String> translate({
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String text,
  });
}
