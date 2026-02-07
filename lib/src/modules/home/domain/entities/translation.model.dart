class TranslationSettingEntity {
  final String sourceLanguageCode;
  final String targetLanguageCode;

  final String? sourceText;
  final String? translatedText;
  TranslationSettingEntity({
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
    this.sourceText,
    this.translatedText,
  });
  static const _noValue = Object();
  TranslationSettingEntity copyWith({
    String? sourceLanguageCode,
    String? targetLanguageCode,
    Object? sourceText = _noValue,
    Object? translatedText = _noValue,
  }) =>
      TranslationSettingEntity(
        sourceLanguageCode: sourceLanguageCode ?? this.sourceLanguageCode,
        targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
        sourceText: sourceText == _noValue ? this.sourceText : sourceText as String?,
        translatedText: translatedText == _noValue ? this.translatedText : translatedText as String?,
      );
}
