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
  late TranslationRepositoryImpl _translator;
  @override
  TranslaorModel build() {
    _translator = TranslationRepositoryImpl();
    return TranslaorModel(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.french,
    );
  }

  void swapLanguage() {
    state = state.copyWith(
      sourceLanguage: state.targetLanguage,
      targetLanguage: state.sourceLanguage,
    );
  }

  void setSourceText(String? s) {
    state = state.copyWith(sourceText: s);
  }

  Future<void> translate() async {
    final translatedText = await _translator.translateText(state.translator, state.sourceText!);
    state = state.copyWith(translatedText: translatedText);
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

  TranslaorModel copyWith({
    TranslateLanguage? sourceLanguage,
    TranslateLanguage? targetLanguage,
    String? sourceText,
    String? translatedText,
  }) =>
      TranslaorModel(
        sourceLanguage: sourceLanguage ?? this.sourceLanguage,
        targetLanguage: targetLanguage ?? this.targetLanguage,
        sourceText: sourceText,
        translatedText: translatedText,
      );
}
