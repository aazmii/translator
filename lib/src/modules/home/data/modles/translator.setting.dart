import 'package:go_translator/src/modules/home/domain/entities/translation.model.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:isar_community/isar.dart';

part 'translator.setting.g.dart';

@Collection()
class TranslatorSetting {
  String? sourceLangCode;
  String? targetLangCode;
  TranslatorSetting();
  final Id id = 0;

  TranslationSettingEntity toDomain() => TranslationSettingEntity(
        sourceLanguage: TranslateLanguage.values.firstWhere((e) => e.name == sourceLangCode),
        targetLanguage: TranslateLanguage.values.firstWhere((e) => e.name == targetLangCode),
      );
  static TranslatorSetting fromDomain(TranslationSettingEntity tSetting) => TranslatorSetting()
    ..sourceLangCode = tSetting.sourceLanguage.name
    ..targetLangCode = tSetting.targetLanguage.name;
}
