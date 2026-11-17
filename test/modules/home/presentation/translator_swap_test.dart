import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation_settings.dart';
import 'package:go_translator/src/modules/home/domain/repositories/translation_repository.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/providers/translator.dart';

void main() {
  late _FakeTranslationRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeTranslationRepository();
    container = ProviderContainer(
      overrides: [translationRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  Future<Translator> ready() async {
    await container.read(translatorProvider.future);
    return container.read(translatorProvider.notifier);
  }

  test('swap with a translation exchanges texts and languages', () async {
    final translator = await ready();
    translator.setSourceText('hello');
    await translator.translate();

    await translator.swapLanguage();

    final state = container.read(translatorProvider).value!;
    expect(state.sourceLanguageCode, 'fr');
    expect(state.targetLanguageCode, 'en');
    expect(state.sourceText, 'translated');
    expect(state.translatedText, 'hello');
  });

  test('swap without a translation swaps languages only', () async {
    final translator = await ready();
    translator.setSourceText('hello');

    await translator.swapLanguage();

    final state = container.read(translatorProvider).value!;
    expect(state.sourceLanguageCode, 'fr');
    expect(state.targetLanguageCode, 'en');
    expect(state.sourceText, 'hello');
    expect(state.translatedText, isNull);
  });

  test('swap saves the swapped languages', () async {
    final translator = await ready();

    await translator.swapLanguage();

    expect(repository.saved?.sourceLanguageCode, 'fr');
    expect(repository.saved?.targetLanguageCode, 'en');
  });
}

final class _FakeTranslationRepository implements TranslationRepository {
  TranslationSettings? saved = const TranslationSettings(
    sourceLanguageCode: 'en',
    targetLanguageCode: 'fr',
  );

  @override
  Future<TranslationSettings?> getSettings() async => saved;

  @override
  Future<void> saveSettings(TranslationSettings settings) async {
    saved = settings;
  }

  @override
  Future<String> translate({
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String text,
  }) async => 'translated';
}
