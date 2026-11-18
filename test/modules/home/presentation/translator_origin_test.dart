import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation_settings.dart';
import 'package:go_translator/src/modules/home/domain/repositories/translation_repository.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/providers/translator.dart';

import '../../../helpers/fake_offline_language_repository.dart';

/// The translator remembers what the current translation was made from, so a
/// bookmark can label it correctly after the selection changed.
void main() {
  late _FakeTranslationRepository repository;
  late FakeOfflineLanguageRepository languages;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeTranslationRepository();
    languages = FakeOfflineLanguageRepository();
    container = ProviderContainer(
      overrides: [
        translationRepositoryProvider.overrideWithValue(repository),
        offlineLanguageRepositoryProvider.overrideWithValue(languages),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<Translator> ready() async {
    await container.read(translatorProvider.future);
    return container.read(translatorProvider.notifier);
  }

  TranslatorState state() => container.read(translatorProvider).value!;

  test('no origin before translating', () async {
    final translator = await ready();
    translator.setSourceText('hello');
    expect(state().translationOrigin, isNull);
  });

  test('a successful translate records the text and both languages', () async {
    final translator = await ready();
    translator.setSourceText('hello');
    await translator.translate();

    final origin = state().translationOrigin!;
    expect(origin.sourceText, 'hello');
    expect(origin.sourceLanguageCode, 'en');
    expect(origin.targetLanguageCode, 'fr');
  });

  test('changing the target language afterwards keeps the old origin', () async {
    final translator = await ready();
    translator.setSourceText('hello');
    await translator.translate();

    await translator.setTargetLanguage('af');

    expect(state().targetLanguageCode, 'af');
    expect(state().translatedText, 'bonjour');
    expect(state().translationOrigin!.targetLanguageCode, 'fr');
  });

  test('editing the text afterwards keeps the old origin text', () async {
    final translator = await ready();
    translator.setSourceText('hello');
    await translator.translate();

    translator.setSourceText('hello there');

    expect(state().translationOrigin!.sourceText, 'hello');
  });

  test('swap with a translation records the swapped pair', () async {
    final translator = await ready();
    translator.setSourceText('hello');
    await translator.translate();

    await translator.swapLanguage();

    final origin = state().translationOrigin!;
    expect(origin.sourceText, 'bonjour');
    expect(origin.sourceLanguageCode, 'fr');
    expect(origin.targetLanguageCode, 'en');
  });

  test('a failed translate clears the origin', () async {
    final translator = await ready();
    translator.setSourceText('hello');
    await translator.translate();

    repository.fail = true;
    await translator.translate();

    expect(state().translatedText, isNull);
    expect(state().translationOrigin, isNull);
  });

  test('a missing language clears the origin', () async {
    final translator = await ready();
    translator.setSourceText('hello');
    await translator.translate();

    languages.notDownloaded.add('fr');
    await translator.translate();

    expect(state().translatedText, isNull);
    expect(state().translationOrigin, isNull);
  });

  test('Clear clears the origin', () async {
    final translator = await ready();
    translator.setSourceText('hello');
    await translator.translate();

    translator.clear();

    expect(state().translationOrigin, isNull);
  });
}

final class _FakeTranslationRepository implements TranslationRepository {
  bool fail = false;

  @override
  Future<TranslationSettings?> getSettings() async =>
      const TranslationSettings(sourceLanguageCode: 'en', targetLanguageCode: 'fr');

  @override
  Future<void> saveSettings(TranslationSettings settings) async {}

  @override
  Future<String> translate({
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String text,
  }) async {
    if (fail) throw Exception('model unavailable');
    return 'bonjour';
  }
}
