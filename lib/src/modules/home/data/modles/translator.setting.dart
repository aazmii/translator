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
        sourceLanguage: TranslateLanguage.values.firstWhere((e) => e.name == sourceLang),
        targetLanguage: TranslateLanguage.values.firstWhere((e) => e.name == targetLang),
      );
  static TranslatorSetting fromDomain(TranslationSettingEntity tSetting) => TranslatorSetting()
    ..id = 0
    ..sourceLang = tSetting.sourceLanguage.name
    ..targetLang = tSetting.targetLanguage.name;
}
