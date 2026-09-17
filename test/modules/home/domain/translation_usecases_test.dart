import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation_settings.dart';
import 'package:go_translator/src/modules/home/domain/repositories/translation_repository.dart';
import 'package:go_translator/src/modules/home/domain/usecases/translate_text.dart';

void main() {
  test('TranslateText validates and normalizes the request', () async {
    final repository = _FakeTranslationRepository();
    final translateText = TranslateText(repository);

    final result = await translateText(
      const TranslateTextParams(
        sourceLanguageCode: 'en',
        targetLanguageCode: 'fr',
        text: '  hello  ',
      ),
    );

    expect(result, 'translated');
    expect(repository.lastText, 'hello');
    expect(repository.lastSourceCode, 'en');
    expect(repository.lastTargetCode, 'fr');
  });

  test('TranslateText rejects blank text', () {
    final translateText = TranslateText(_FakeTranslationRepository());

    expect(
      () => translateText(
        const TranslateTextParams(
          sourceLanguageCode: 'en',
          targetLanguageCode: 'fr',
          text: ' ',
        ),
      ),
      throwsArgumentError,
    );
  });
}

final class _FakeTranslationRepository implements TranslationRepository {
  String? lastSourceCode;
  String? lastTargetCode;
  String? lastText;

  @override
  Future<TranslationSettings?> getSettings() async => null;

  @override
  Future<void> saveSettings(TranslationSettings settings) async {}

  @override
  Future<String> translate({
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String text,
  }) async {
    lastSourceCode = sourceLanguageCode;
    lastTargetCode = targetLanguageCode;
    lastText = text;
    return 'translated';
  }
}
