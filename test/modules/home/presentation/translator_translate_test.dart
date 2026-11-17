import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation_settings.dart';
import 'package:go_translator/src/modules/home/domain/repositories/translation_repository.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/providers/translator.dart';

import '../../../helpers/fake_offline_language_repository.dart';

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

  /// Translates 'hello' en->fr successfully, then sets new source text.
  Future<Translator> withOldTranslation(String newText) async {
    final translator = await ready();
    translator.setSourceText('hello');
    await translator.translate();
    translator.setSourceText(newText);
    return translator;
  }

  test('success stores the result', () async {
    final translator = await ready();
    translator.setSourceText('hello');

    expect(await translator.translate(), isA<TranslateSucceeded>());
    expect(container.read(translatorProvider).value!.translatedText, 'bonjour');
  });

  test('failure clears the old translation and keeps the rest', () async {
    final translator = await withOldTranslation('goodbye');
    repository.fail = true;

    expect(await translator.translate(), isA<TranslateFailed>());
    final state = container.read(translatorProvider).value!;
    expect(state.translatedText, isNull);
    expect(state.sourceText, 'goodbye');
    expect(state.sourceLanguageCode, 'en');
    expect(state.targetLanguageCode, 'fr');
  });

  test('empty source succeeds without calling the repository', () async {
    final translator = await ready();
    translator.setSourceText('   ');

    expect(await translator.translate(), isA<TranslateSucceeded>());
    expect(repository.translateCalls, 0);
  });

  test('missing target model skips ML Kit and clears the old translation', () async {
    final translator = await withOldTranslation('goodbye');
    final callsBefore = repository.translateCalls;
    languages.notDownloaded.add('fr');

    final outcome = await translator.translate();

    expect(outcome, isA<TranslateLanguagesMissing>());
    expect((outcome as TranslateLanguagesMissing).languageNames, ['french']);
    expect(repository.translateCalls, callsBefore);
    expect(container.read(translatorProvider).value!.translatedText, isNull);
  });

  test('missing source model is reported', () async {
    final translator = await ready();
    translator.setSourceText('hello');
    languages.notDownloaded.add('en');

    final outcome = await translator.translate();

    expect((outcome as TranslateLanguagesMissing).languageNames, ['english']);
    expect(repository.translateCalls, 0);
  });

  test('both models missing are reported, source first', () async {
    final translator = await ready();
    translator.setSourceText('hello');
    languages.notDownloaded.addAll(['en', 'fr']);

    final outcome = await translator.translate();

    expect((outcome as TranslateLanguagesMissing).languageNames, ['english', 'french']);
    expect(repository.translateCalls, 0);
  });
}

final class _FakeTranslationRepository implements TranslationRepository {
  bool fail = false;
  int translateCalls = 0;

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
    translateCalls++;
    if (fail) throw Exception('model unavailable');
    return 'bonjour';
  }
}
