import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationSettingEntity {
  final TranslateLanguage sourceLanguage, targetLanguage;

  final String? sourceText, translatedText;

  final OnDeviceTranslator translator;
  TranslationSettingEntity({
    required this.sourceLanguage,
    required this.targetLanguage,
    this.sourceText,
    this.translatedText,
  }) : translator = OnDeviceTranslator(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage);
  static const _noValue = Object();
  TranslationSettingEntity copyWith({
    TranslateLanguage? sourceLanguage,
    TranslateLanguage? targetLanguage,
    Object? sourceText = _noValue,
    Object? translatedText = _noValue,
  }) =>
      TranslationSettingEntity(
        sourceLanguage: sourceLanguage ?? this.sourceLanguage,
        targetLanguage: targetLanguage ?? this.targetLanguage,
        sourceText: sourceText == _noValue ? this.sourceText : sourceText as String?,
        translatedText: translatedText == _noValue ? this.translatedText : translatedText as String?,
      );
}
