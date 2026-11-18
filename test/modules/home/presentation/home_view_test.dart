import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation_settings.dart';
import 'package:go_translator/src/modules/home/domain/repositories/translation_repository.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/home.view.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/providers/translator.dart';
import 'package:go_translator/src/modules/setting/domain/entities/setting.entity.dart';
import 'package:go_translator/src/modules/setting/domain/repositories/setting.repo.dart';
import 'package:go_translator/src/theme/themes/dark/dark.theme.dart';
import 'package:go_translator/src/theme/themes/light/light.theme.dart';

import '../../../helpers/fake_offline_language_repository.dart';

const _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');

/// Loads the bundled Inter so text is measured at its real width (the test
/// font draws every glyph as a wide square).
Future<void> _loadInter() async {
  final loader = FontLoader('Inter');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    loader.addFont(rootBundle.load('assets/fonts/Inter-$weight.ttf'));
  }
  await loader.load();
}

void main() {
  late ProviderContainer container;

  setUpAll(_loadInter);

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _toastChannel,
      (_) async => true,
    );
  });

  tearDown(() {
    container.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_toastChannel, null);
  });

  /// Pumps the translator page on a typical phone screen (390 x 844).
  Future<void> pumpHome(WidgetTester tester, {ThemeData? theme, Size size = const Size(390, 844)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: [
        translationRepositoryProvider.overrideWithValue(_FakeTranslationRepository()),
        offlineLanguageRepositoryProvider.overrideWithValue(FakeOfflineLanguageRepository()),
        // Keyboard off so the page renders without focus side effects.
        settingsRepositoryProvider.overrideWithValue(_FakeSettingsRepository()),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: theme ?? lightTheme, home: const HomeView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  TranslatorState state() => container.read(translatorProvider).value!;

  bool enabled(WidgetTester tester, String tooltip) =>
      tester.widget<IconButton>(find.widgetWithIcon(IconButton, _icons[tooltip]!)).onPressed != null;

  for (final (name, theme) in [('light', lightTheme), ('dark', darkTheme)]) {
    testWidgets('lays out without overflow in $name mode', (tester) async {
      await pumpHome(tester, theme: theme);
      expect(tester.takeException(), isNull);
      expect(find.text('Translator'), findsOneWidget);
    });
  }

  testWidgets('a small phone (320 x 568) keeps the Translate pill, scaled to fit', (tester) async {
    await pumpHome(tester, size: const Size(320, 568));
    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(FilledButton, 'Translate'), findsOneWidget);
    expect(find.ancestor(of: find.byType(FilledButton), matching: find.byType(FittedBox)), findsOneWidget);
  });

  for (final width in [360.0, 390.0]) {
    testWidgets('a ${width.toInt()}px-wide phone shows the toolbar at full design size', (tester) async {
      await pumpHome(tester, size: Size(width, 780));
      expect(tester.takeException(), isNull);
      expect(find.ancestor(of: find.byType(FilledButton), matching: find.byType(FittedBox)), findsNothing);
    });
  }

  testWidgets('the Translate pill matches the design (44px high, 6px gap, 18px arrow)', (tester) async {
    await pumpHome(tester);
    final button = find.widgetWithText(FilledButton, 'Translate');
    expect(tester.getSize(button).height, 44);
    final label = tester.getRect(find.descendant(of: button, matching: find.text('Translate')));
    final arrow = tester.getRect(find.descendant(of: button, matching: find.byIcon(Icons.arrow_downward)));
    expect(arrow.left - label.right, 6);
    expect(arrow.width, 18);
    expect(label.left - tester.getRect(button).left, 16);
  });

  testWidgets('no overflow with long language names and the largest text size', (tester) async {
    await pumpHome(tester, size: const Size(320, 568));
    await container.read(translatorProvider.notifier).setSourceLanguage('af');
    await tester.enterText(find.byType(EditableText).first, 'a long sentence ' * 20);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the language bar shows both languages', (tester) async {
    await pumpHome(tester);
    expect(
      find.descendant(of: find.byKey(const Key('sourceLanguagePill')), matching: find.text('English')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byKey(const Key('targetLanguagePill')), matching: find.text('French')),
      findsOneWidget,
    );
  });

  testWidgets('the translation card shows the target language and On-device', (tester) async {
    await pumpHome(tester);
    expect(find.text('FRENCH'), findsOneWidget);
    expect(find.text('On-device'), findsOneWidget);
  });

  testWidgets('empty source: the card shows only the field; only the mic works', (tester) async {
    await pumpHome(tester);
    expect(find.text('Ready to translate anywhere'), findsNothing);
    expect(find.text('Paste'), findsNothing);
    expect(find.byTooltip('Clear text'), findsNothing);
    expect(enabled(tester, 'Speak'), isTrue);
    expect(enabled(tester, 'Bookmark'), isFalse);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
  });

  testWidgets('typing enables Translate, bookmark and Clear; Translate translates', (tester) async {
    await pumpHome(tester);
    await tester.enterText(find.byType(EditableText).first, 'hello');
    await tester.pumpAndSettle();

    expect(find.text('Ready to translate anywhere'), findsNothing);
    expect(find.byTooltip('Clear text'), findsOneWidget);
    expect(enabled(tester, 'Bookmark'), isTrue);

    await tester.tap(find.text('Translate'));
    await tester.pumpAndSettle();
    expect(state().translatedText, 'translated');
    expect(enabled(tester, 'Share'), isTrue);
  });

  testWidgets('Clear empties the source and translation', (tester) async {
    await pumpHome(tester);
    await tester.enterText(find.byType(EditableText).first, 'hello');
    await tester.tap(find.text('Translate'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Clear text'));
    await tester.pumpAndSettle();
    expect(state().sourceText, anyOf(isNull, isEmpty));
    expect(state().translatedText, anyOf(isNull, isEmpty));
    expect(find.byTooltip('Clear text'), findsNothing);
  });

  testWidgets('the swap button swaps the languages', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byTooltip('Swap languages'));
    await tester.pumpAndSettle();
    expect(state().sourceLanguageCode, 'fr');
    expect(state().targetLanguageCode, 'en');
    expect(
      find.descendant(of: find.byKey(const Key('sourceLanguagePill')), matching: find.text('French')),
      findsOneWidget,
    );
  });
}

const _icons = {
  'Speak': Icons.mic_none,
  'Bookmark': Icons.star_outline,
  'Share': Icons.share_outlined,
};

final class _FakeSettingsRepository implements SettingsRepository {
  AppSettings settings = const AppSettings(showKeyboardAtStartup: false);

  @override
  Future<AppSettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(AppSettings settings) async => this.settings = settings;
}

final class _FakeTranslationRepository implements TranslationRepository {
  TranslationSettings? saved = const TranslationSettings(sourceLanguageCode: 'en', targetLanguageCode: 'fr');

  @override
  Future<TranslationSettings?> getSettings() async => saved;

  @override
  Future<void> saveSettings(TranslationSettings settings) async => saved = settings;

  @override
  Future<String> translate({
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String text,
  }) async => 'translated';
}
