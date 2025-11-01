import 'package:go_translator/src/modules/home/data/repository/translation.repo.impl.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'translator.g.dart';
// final userProvider = FutureProvider<User>((ref) async {
//   final response = await http.get('https://api.example.com/user/123');
//   return User.fromJson(response.body);
// });

// final sourceLanguageProvider = Provider((ref) => TranslateLanguage.english);

@Riverpod(keepAlive: true)
class Translator extends _$Translator {
  late HomeRepositoryImpl _homeRepo;
  @override
  TranslaorModel build() {
    _homeRepo = HomeRepositoryImpl();
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

class TranslaorModel {
  final TranslateLanguage sourceLanguage, targetLanguage;

  final String? sourceText, translatedText;

  final OnDeviceTranslator translator;
  TranslaorModel({
    required this.sourceLanguage,
    required this.targetLanguage,
    this.sourceText,
    this.translatedText,
  }) : translator = OnDeviceTranslator(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage);
  static const _noValue = Object();
  TranslaorModel copyWith({
    TranslateLanguage? sourceLanguage,
    TranslateLanguage? targetLanguage,
    Object? sourceText = _noValue,
    Object? translatedText = _noValue,
  }) =>
      TranslaorModel(
        sourceLanguage: sourceLanguage ?? this.sourceLanguage,
        targetLanguage: targetLanguage ?? this.targetLanguage,
        sourceText: sourceText == _noValue ? this.sourceText : sourceText as String?,
        translatedText: translatedText == _noValue ? this.translatedText : translatedText as String?,
      );
}
