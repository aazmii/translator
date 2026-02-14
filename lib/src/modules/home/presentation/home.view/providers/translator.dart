import 'package:go_translator/src/core/di/providers.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation.model.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:go_translator/src/modules/home/domain/repository/home.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'translator.g.dart';

@Riverpod(keepAlive: true)
class Translator extends _$Translator {
  late TranslationRpository _translatorRepo;
  @override
  Future<TranslationSettingEntity?> build() async {
    _translatorRepo = ref.read(translationRepositoryProvider);

    // try to fetch saved settings
    final saved = await _translatorRepo.getTranslationSetting();

    // if no record exists, create default and persist it
    if (saved == null) {
      final defaultSetting = TranslationSettingEntity(
        sourceLanguageCode: TranslateLanguage.english.bcpCode,
        targetLanguageCode: TranslateLanguage.french.bcpCode,
      );
      await _translatorRepo.saveTranslationSetting(defaultSetting);
      return defaultSetting;
    }

    return saved;
  }

  TranslationSettingEntity? get value => state.value;
  Future<void> swapLanguage() async {
    state = AsyncData(value?.copyWith(
      sourceLanguageCode: value?.targetLanguageCode,
      targetLanguageCode: value?.sourceLanguageCode,
    ));
    await _translatorRepo.saveTranslationSetting(value!);
  }

  void setSourceText(String? s) {
    state = AsyncData(value?.copyWith(sourceText: s));
  }

  Future<void> translate() async {
    if (value?.sourceText == null || value!.sourceText!.isEmpty) return;
    final translatedText = await _translatorRepo.translateText(
      sourceLanguageCode: value!.sourceLanguageCode,
      targetLanguageCode: value!.targetLanguageCode,
      text: value!.sourceText!,
    );
    state = AsyncData(value?.copyWith(translatedText: translatedText));
  }

  set setSourceLanguage(String code) {
    if (code == value?.targetLanguageCode) swapLanguage();
    state = AsyncData(value?.copyWith(sourceLanguageCode: code));
    _translatorRepo.saveTranslationSetting(value!);
  }

  set setTargetLanguage(String code) {
    if (code == value?.targetLanguageCode) swapLanguage();
    state = AsyncData(value?.copyWith(targetLanguageCode: code));
    _translatorRepo.saveTranslationSetting(value!);
  }

  void clear() {
    state = AsyncData(value?.copyWith(sourceText: null, translatedText: null));
  }
}
