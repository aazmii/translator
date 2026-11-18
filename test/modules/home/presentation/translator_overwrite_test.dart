import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation_settings.dart';
import 'package:go_translator/src/modules/home/domain/repositories/translation_repository.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/providers/translator.dart';

import '../../../helpers/fake_offline_language_repository.dart';

/// Changes made while translate() is waiting for ML Kit must survive.
void main() {
  late _PausableTranslationRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _PausableTranslationRepository();
    container = ProviderContainer(
      overrides: [
        translationRepositoryProvider.overrideWithValue(repository),
        offlineLanguageRepositoryProvider.overrideWithValue(FakeOfflineLanguageRepository()),
      ],
    );
  });

  tearDown(() => container.dispose());

  TranslatorState state() => container.read(translatorProvider).value!;

  /// Translates 'hello' en->fr to 'bonjour' without pausing.
  Future<Translator> translatedHello() async {
    await container.read(translatorProvider.future);
    final translator = container.read(translatorProvider.notifier);
    translator.setSourceText('hello');
    await translator.translate();
    return translator;
  }

  /// Starts translating [text] and waits until ML Kit has been called.
  Future<Future<TranslateOutcome>> startPaused(Translator translator, String text) async {
    translator.setSourceText(text);
    repository.pending = Completer<String>();
    final outcome = translator.translate();
    await repository.called.future;
    return outcome;
  }

  test('no change while waiting: the result is stored', () async {
    final translator = await translatedHello();
    final outcome = await startPaused(translator, 'goodbye');

    repository.pending!.complete('au revoir');

    expect(await outcome, isA<TranslateSucceeded>());
    expect(state().sourceText, 'goodbye');
    expect(state().translatedText, 'au revoir');
  });

  test('text edited while waiting: the result is dropped and the edit kept', () async {
    final translator = await translatedHello();
    final outcome = await startPaused(translator, 'goodbye');

    translator.setSourceText('goodbye friend');
    repository.pending!.complete('au revoir');

    expect(await outcome, isA<TranslateSuperseded>());
    expect(state().sourceText, 'goodbye friend');
    expect(state().translatedText, 'bonjour');
  });

  test('swap while waiting: the swapped languages and texts are kept', () async {
    final translator = await translatedHello();
    final outcome = await startPaused(translator, 'hello');

    await translator.swapLanguage();
    repository.pending!.complete('salut');

    expect(await outcome, isA<TranslateSuperseded>());
    expect(state().sourceLanguageCode, 'fr');
    expect(state().targetLanguageCode, 'en');
    expect(state().sourceText, 'bonjour');
    expect(state().translatedText, 'hello');
  });

  test('swap while a failing translation waits: the moved text is not cleared', () async {
    final translator = await translatedHello();
    final outcome = await startPaused(translator, 'hello');

    await translator.swapLanguage();
    repository.pending!.completeError(Exception('model unavailable'));

    expect(await outcome, isA<TranslateSuperseded>());
    expect(state().sourceText, 'bonjour');
    expect(state().translatedText, 'hello');
  });

  test('a failure with no change still clears the old translation', () async {
    final translator = await translatedHello();
    final outcome = await startPaused(translator, 'goodbye');

    repository.pending!.completeError(Exception('model unavailable'));

    expect(await outcome, isA<TranslateFailed>());
    expect(state().translatedText, isNull);
  });
}

/// Returns 'bonjour' at once, or, when [pending] is set, waits for it.
final class _PausableTranslationRepository implements TranslationRepository {
  Completer<String>? pending;
  Completer<void> called = Completer<void>();

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
  }) {
    final waiting = pending;
    if (waiting == null) return Future.value('bonjour');
    if (!called.isCompleted) called.complete();
    return waiting.future;
  }
}
