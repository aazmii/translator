import 'package:go_translator/src/modules/home/data/modles/translator.setting.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation.model.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:isar_community/isar.dart' show Isar;

import '../../domain/repository/home.repository.dart';

class TranslationRepositoryImpl implements TranslationRpository {
  final Isar db;
  TranslationRepositoryImpl(this.db);
  @override
  Future<String?> translateText(OnDeviceTranslator translator, String text) {
    return translator.translateText(text);
  }

  @override
  Future<TranslationSettingEntity?> getTranslationSetting() async {
    final tSetting = await db.translatorSettings.get(0);
    return tSetting?.toDomain();
  }

  @override
  Future saveTranslationSetting(TranslationSettingEntity tSetting) async {
    await db.writeTxn(() async {
      await db.translatorSettings.put(TranslatorSetting.fromDomain(tSetting));
    });
  }
}
