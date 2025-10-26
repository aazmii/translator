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

  void clear() {
    state = state.copyWith(sourceText: null, translatedText: null);
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

    //     Object? name = _noValue,
    // Object? age = _noValue,
  }) : translator = OnDeviceTranslator(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage);
  static const _noValue = Object();
  TranslaorModel copyWith({
    TranslateLanguage? sourceLanguage,
    TranslateLanguage? targetLanguage,
    Object? sourceText = _noValue,
    Object? translatedText = _noValue,

    // String? sourceText,
    // String? translatedText,
  }) =>
      TranslaorModel(
        sourceLanguage: sourceLanguage ?? this.sourceLanguage,
        targetLanguage: targetLanguage ?? this.targetLanguage,
        sourceText: sourceText == _noValue ? this.sourceText : sourceText as String?,
        translatedText: translatedText == _noValue ? this.translatedText : translatedText as String?,
        //        name: name == _noValue ? this.name : name as String?,
        // age: age == _noValue ? this.age : age as int?,
      );
}
