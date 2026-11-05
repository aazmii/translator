final class TranslationSettings {
  const TranslationSettings({
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
  });

  final String sourceLanguageCode;
  final String targetLanguageCode;

  TranslationSettings copyWith({
    String? sourceLanguageCode,
    String? targetLanguageCode,
  }) {
    return TranslationSettings(
      sourceLanguageCode: sourceLanguageCode ?? this.sourceLanguageCode,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
    );
  }
}
