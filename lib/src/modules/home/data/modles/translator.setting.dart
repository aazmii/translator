import 'package:go_translator/src/modules/home/domain/entities/translation.model.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:isar_community/isar.dart';

part 'translator.setting.g.dart';

@Collection()
class TranslatorSetting {
  String? sourceLang;
  String? targetLang;
  String? json;
  Id id = 0;

  TranslatorSetting();

  TranslationSettingEntity toDomain() => TranslationSettingEntity(
        sourceLanguageCode: _toBcpCode(sourceLang, fallback: TranslateLanguage.english),
        targetLanguageCode: _toBcpCode(targetLang, fallback: TranslateLanguage.french),
      );
  static TranslatorSetting fromDomain(TranslationSettingEntity tSetting) => TranslatorSetting()
    ..id = 0
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
