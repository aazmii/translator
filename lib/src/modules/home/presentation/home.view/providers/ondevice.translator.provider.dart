import 'package:flutter_riverpod/legacy.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ondevice.translator.provider.g.dart';
// final userProvider = FutureProvider<User>((ref) async {
//   final response = await http.get('https://api.example.com/user/123');
//   return User.fromJson(response.body);
// });

final sourceLanguageProvider = StateProvider<TranslateLanguage>((ref) {
  return TranslateLanguage.english;
});
final targetLanguageProvider = StateProvider<TranslateLanguage>((ref) {
  return TranslateLanguage.french;
});
// final sourceLanguageProvider = Provider((ref) => TranslateLanguage.english);

@Riverpod(keepAlive: true)
class OnDeviceTranslatorP extends _$OnDeviceTranslatorP {
  @override
  OnDeviceTranslator build() {
    return OnDeviceTranslator(
      sourceLanguage: ref.watch(sourceLanguageProvider),
      targetLanguage: ref.watch(targetLanguageProvider),
    );
  }

  void swapLanguage() {
    final currentSource = ref.read(sourceLanguageProvider);
    final currentTarget = ref.read(targetLanguageProvider);

    ref.read(sourceLanguageProvider.notifier).state = currentTarget;
    ref.read(targetLanguageProvider.notifier).state = currentSource;
  }
}
