import 'dart:convert' show json;

import 'package:go_translator/src/modules/home/domain/entities/translation.model.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslatorSetting {
  String? sourceLang;
  String? targetLang;

  TranslatorSetting();

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'sourceLang': sourceLang,
        'targetLang': targetLang,
      };

  factory TranslatorSetting.fromJson(String source) =>
      TranslatorSetting.fromRawJson(json.decode(source) as Map<String, dynamic>);

  factory TranslatorSetting.fromRawJson(Map<String, dynamic> raw) => TranslatorSetting()
    ..sourceLang = raw['sourceLang'] as String?
    ..targetLang = raw['targetLang'] as String?;

  TranslationSettingEntity toDomain() => TranslationSettingEntity(
        sourceLanguageCode: _toBcpCode(sourceLang, fallback: TranslateLanguage.english),
        targetLanguageCode: _toBcpCode(targetLang, fallback: TranslateLanguage.french),
      );
  static TranslatorSetting fromDomain(TranslationSettingEntity tSetting) => TranslatorSetting()
    ..sourceLang = tSetting.sourceLanguageCode
    ..targetLang = tSetting.targetLanguageCode;
}

String _toBcpCode(String? value, {required TranslateLanguage fallback}) {
  if (value == null || value.isEmpty) return fallback.bcpCode;
  final byCode = TranslateLanguage.values.firstWhere(
    (e) => e.bcpCode == value,
    orElse: () => fallback,
  );
  if (byCode.bcpCode == value) return byCode.bcpCode;
  final byName = TranslateLanguage.values.firstWhere(
    (e) => e.name == value,
    orElse: () => fallback,
  );
  return byName.bcpCode;
}
