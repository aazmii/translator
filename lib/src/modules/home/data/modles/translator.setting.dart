import 'package:isar_community/isar.dart';

import '../../domain/entities/translator.setting.dart';
part 'translator.setting.g.dart';

@Collection()
class TranslatorSetting {
  String? sourceLangCode;
  String? targetLangCode;
  TranslatorSetting();
  final Id id = 0;

  TranslatorSettingEntity toDomain() => TranslatorSettingEntity(
        sourceLanguageCode: sourceLangCode,
        targetLanguageCode: targetLangCode,
      );
  static TranslatorSetting fromDomain(TranslatorSettingEntity tSetting) => TranslatorSetting()
    ..sourceLangCode = tSetting.sourceLanguageCode
    ..targetLangCode = tSetting.targetLanguageCode;
}
