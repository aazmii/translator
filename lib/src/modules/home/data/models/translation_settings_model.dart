import 'dart:convert';

import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../domain/entities/translation_settings.dart';

final class TranslationSettingsModel {
  const TranslationSettingsModel({
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
  });

  final String sourceLanguageCode;
  final String targetLanguageCode;

  factory TranslationSettingsModel.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return TranslationSettingsModel(
      sourceLanguageCode: _languageCode(map['sourceLang'], fallback: 'en'),
      targetLanguageCode: _languageCode(map['targetLang'], fallback: 'fr'),
    );
  }

  factory TranslationSettingsModel.fromEntity(TranslationSettings settings) {
    return TranslationSettingsModel(
      sourceLanguageCode: settings.sourceLanguageCode,
      targetLanguageCode: settings.targetLanguageCode,
    );
  }

  TranslationSettings toEntity() => TranslationSettings(
    sourceLanguageCode: sourceLanguageCode,
    targetLanguageCode: targetLanguageCode,
  );

  String toJson() => jsonEncode({
    'sourceLang': sourceLanguageCode,
    'targetLang': targetLanguageCode,
  });
}

String _languageCode(Object? value, {required String fallback}) {
  if (value is! String || value.trim().isEmpty) return fallback;

  final fallbackLanguage = TranslateLanguage.values.firstWhere(
    (language) => language.bcpCode == fallback,
    orElse: () => TranslateLanguage.english,
  );
  return TranslateLanguage.values
      .firstWhere(
        (language) => language.bcpCode == value || language.name == value,
        orElse: () => fallbackLanguage,
      )
      .bcpCode;
}
