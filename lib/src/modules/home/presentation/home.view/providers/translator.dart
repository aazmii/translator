import 'package:go_translator/src/core/di/providers.dart';
import 'package:go_translator/src/modules/home/data/repository/translation.repo.impl.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation.model.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:isar_community/isar.dart' show Isar;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'translator.g.dart';

@Riverpod(keepAlive: true)
class Translator extends _$Translator {
  late HomeRepositoryImpl _homeRepo;
  late final Isar db;

  @override
  TranslaorModel build() {
    db = ref.read(isarProvider); // inject dependency
    _homeRepo = HomeRepositoryImpl(db);

    return TranslaorModel(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.french,
    );
  }

  Future<void> swapLanguage() async {
    state = state.copyWith(
      sourceLanguage: state.targetLanguage,
      targetLanguage: state.sourceLanguage,
    );
  }

  void clear() {
    state = state.copyWith(sourceText: null, translatedText: null);
  }

  void setSourceText(String? s) {
    state = state.copyWith(sourceText: s);
  }

  Future<void> translate() async {
    if (state.sourceText == null || state.sourceText!.isEmpty) return;
    final translatedText = await _homeRepo.translateText(state.translator, state.sourceText!);
    state = state.copyWith(translatedText: translatedText);
  }

  set setSourceLanguage(String code) {
    if (code == state.targetLanguage.bcpCode) swapLanguage();
    final sourceLanguage = TranslateLanguage.values.firstWhere((e) => e.bcpCode == code);
    state = state.copyWith(sourceLanguage: sourceLanguage);
  }

  set setTargetLanguage(String code) {
    if (code == state.targetLanguage.bcpCode) swapLanguage();
    final targetLanguage = TranslateLanguage.values.firstWhere((e) => e.bcpCode == code);

    state = state.copyWith(targetLanguage: targetLanguage);
  }
}
