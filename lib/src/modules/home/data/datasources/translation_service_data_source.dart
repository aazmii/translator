import 'package:google_mlkit_translation/google_mlkit_translation.dart';

abstract interface class TranslationServiceDataSource {
  Future<String> translate({
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String text,
  });
}

final class MlKitTranslationServiceDataSource
    implements TranslationServiceDataSource {
  const MlKitTranslationServiceDataSource();

  @override
  Future<String> translate({
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
}

TranslateLanguage _languageFromCode(String code) {
  return TranslateLanguage.values.firstWhere(
    (language) => language.bcpCode == code,
    orElse: () => TranslateLanguage.english,
  );
}
