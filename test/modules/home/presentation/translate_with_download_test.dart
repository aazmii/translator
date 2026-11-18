import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation_settings.dart';
import 'package:go_translator/src/modules/home/domain/repositories/translation_repository.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/helpers/translate.with.download.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/providers/translator.dart';

import '../../../helpers/fake_offline_language_repository.dart';

const _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
const _toastTimer = Duration(seconds: 2);

void main() {
  late _CountingTranslationRepository repository;
  late FakeOfflineLanguageRepository languages;
  late ProviderContainer container;
  late List<String> toasts;

  setUp(() {
    repository = _CountingTranslationRepository();
    languages = FakeOfflineLanguageRepository();
    container = ProviderContainer(
      overrides: [
        translationRepositoryProvider.overrideWithValue(repository),
        offlineLanguageRepositoryProvider.overrideWithValue(languages),
      ],
    );
    toasts = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_toastChannel, (call) async {
      if (call.method == 'showToast') toasts.add((call.arguments as Map)['msg'] as String);
      return true;
    });
  });

  tearDown(() {
    container.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_toastChannel, null);
  });

  TranslatorState state() => container.read(translatorProvider).value!;

  /// Sets 'hello' (en -> fr) and taps a button that runs the helper.
  Future<void> translateHello(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () => translateOrOfferDownload(context, ref),
              child: const Text('translate'),
            ),
          ),
        ),
      ),
    );
    await container.read(translatorProvider.future);
    container.read(translatorProvider.notifier).setSourceText('hello');
    await tester.tap(find.text('translate'));
    await tester.pumpAndSettle();
  }

  Future<void> tapDownload(WidgetTester tester) async {
    await tester.tap(find.text('Download'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('nothing missing: translates without a prompt', (tester) async {
    await translateHello(tester);

    expect(find.byType(AlertDialog), findsNothing);
    expect(state().translatedText, 'bonjour');
  });

  testWidgets('missing target: prompt, download, then translate', (tester) async {
    languages.notDownloaded.add('fr');
    languages.pendingDownload = Completer<bool>();
    await translateHello(tester);

    expect(find.text('Download French?'), findsOneWidget);
    expect(repository.translateCalls, 0);

    await tapDownload(tester);
    expect(find.text('Downloading French…'), findsOneWidget);

    languages.pendingDownload!.complete(true);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(languages.downloads, [(code: 'fr', wifiOnly: false)]);
    expect(repository.translateCalls, 1);
    expect(state().translatedText, 'bonjour');
    expect(toasts, isEmpty);
  });

  testWidgets('declining the prompt downloads and translates nothing', (tester) async {
    languages.notDownloaded.add('fr');
    await translateHello(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(languages.downloads, isEmpty);
    expect(repository.translateCalls, 0);
    expect(toasts, isEmpty);
  });

  testWidgets('a failed download shows a message and does not translate', (tester) async {
    languages.notDownloaded.add('fr');
    languages.pendingDownload = Completer<bool>();
    await translateHello(tester);
    await tapDownload(tester);

    languages.pendingDownload!.complete(false);
    await tester.pumpAndSettle();

    expect(repository.translateCalls, 0);
    expect(toasts, ["Couldn't download French. Check your connection and try again."]);
    await tester.pump(_toastTimer);
  });

  testWidgets('cancelling the loader does not translate', (tester) async {
    languages.notDownloaded.add('fr');
    languages.pendingDownload = Completer<bool>();
    await translateHello(tester);
    await tapDownload(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    languages.pendingDownload!.complete(true);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(repository.translateCalls, 0);
    expect(toasts, isEmpty);
  });

  testWidgets('both missing: one prompt, two downloads in order, then translate', (tester) async {
    languages.notDownloaded.addAll(['en', 'fr']);
    await translateHello(tester);

    expect(find.text('Download English and French?'), findsOneWidget);
    await tapDownload(tester);
    await tester.pumpAndSettle();

    expect(languages.downloads.map((d) => d.code), ['en', 'fr']);
    expect(repository.translateCalls, 1);
    expect(state().translatedText, 'bonjour');
  });
}

final class _CountingTranslationRepository implements TranslationRepository {
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
    return 'bonjour';
  }
}
