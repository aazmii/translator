import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../models/language_model.dart';

abstract interface class LanguageModelDataSource {
  Future<List<LanguageModel>> getLanguages();
  Future<bool> download(String code);
  Future<bool> delete(String code);
}

final class MlKitLanguageModelDataSource implements LanguageModelDataSource {
  MlKitLanguageModelDataSource({OnDeviceTranslatorModelManager? modelManager})
    : _modelManager = modelManager ?? OnDeviceTranslatorModelManager();

  final OnDeviceTranslatorModelManager _modelManager;

  @override
  Future<List<LanguageModel>> getLanguages() {
    return Future.wait(
      TranslateLanguage.values.map((language) async {
        return LanguageModel(
          name: language.name,
          code: language.bcpCode,
          isDownloaded: await _modelManager.isModelDownloaded(language.bcpCode),
        );
      }),
    );
  }

  @override
  Future<bool> download(String code) => _modelManager.downloadModel(code);

  @override
  Future<bool> delete(String code) => _modelManager.deleteModel(code);
}
