import 'package:go_translator/src/core/di/providers.dart';
import 'package:go_translator/src/modules/home/data/repository/translation.repo.impl.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation.model.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:isar_community/isar.dart' show Isar;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'translator.g.dart';

@Riverpod(keepAlive: true)
class Translator extends _$Translator {
  late TranslationRepositoryImpl _translatorRepo;
  late final Isar db;
  @override
  Future<TranslationSettingEntity?> build() async {
    db = ref.read(isarProvider);
    _translatorRepo = TranslationRepositoryImpl(db);

    // try to fetch saved settings
    final saved = await _translatorRepo.getTranslationSetting();

    // if no record exists, create default and persist it
    if (saved == null) {
      final defaultSetting = TranslationSettingEntity(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.french,
      );
      await _translatorRepo.saveTranslationSetting(defaultSetting);
      return defaultSetting;
    }

    return saved;
  }

  TranslationSettingEntity? get value => state.value;
  Future<void> swapLanguage() async {
    state = AsyncData(value?.copyWith(
      sourceLanguage: value?.targetLanguage,
      targetLanguage: value?.sourceLanguage,
    ));
    await _translatorRepo.saveTranslationSetting(value!);
  }

  void setSourceText(String? s) {
    state = AsyncData(value?.copyWith(sourceText: s));
  }

  Future<void> translate() async {
    if (value?.sourceText == null || value!.sourceText!.isEmpty) return;
    final translatedText = await _translatorRepo.translateText(value!.translator, value!.sourceText!);
    state = AsyncData(value?.copyWith(translatedText: translatedText));
  }

  set setSourceLanguage(String code) {
    if (code == value?.targetLanguage.bcpCode) swapLanguage();
    final sourceLanguage = TranslateLanguage.values.firstWhere((e) => e.bcpCode == code);
    state = AsyncData(value?.copyWith(sourceLanguage: sourceLanguage));
    _translatorRepo.saveTranslationSetting(value!);
  }

  set setTargetLanguage(String code) {
    if (code == value?.targetLanguage.bcpCode) swapLanguage();
    final targetLanguage = TranslateLanguage.values.firstWhere((e) => e.bcpCode == code);

    state = AsyncData(value?.copyWith(targetLanguage: targetLanguage));
    _translatorRepo.saveTranslationSetting(value!);
  }

  void clear() {
    state = AsyncData(value?.copyWith(sourceText: null, translatedText: null));
  }
}
