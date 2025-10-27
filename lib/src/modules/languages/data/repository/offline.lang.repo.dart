import 'package:go_translator/src/core/domain/entities/language.entity.dart';
import 'package:go_translator/src/modules/languages/domain/repository/offline.translation.reopsitory.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class OfflineLanguageRepositoryImpl implements OfflineLanguageRepository {
  final _modelManager = OnDeviceTranslatorModelManager();
  @override
  Future<List<LanguageEntity>> getAvailableLanguages() async {
    final languages = await Future.wait(
      TranslateLanguage.values.map((t) async {
        final isDownloaded = await _modelManager.isModelDownloaded(t.bcpCode);
        return LanguageEntity(name: t.name, code: t.bcpCode, isDownloaded: isDownloaded);
      }),
    );
    return languages;
  }

  @override
  Future<bool> downloadLanguage(String code) async {
    return await _modelManager.downloadModel(code);
  }

  @override
  Future<bool> deleteLanguage(String code) async {
    return await _modelManager.deleteModel(code);
  }
}
