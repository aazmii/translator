import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/modules/bookmarks/domain/entities/bookmark.entity.dart';
import 'package:go_translator/src/modules/bookmarks/domain/repositories/bookmarks_repository.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation_settings.dart';
import 'package:go_translator/src/modules/home/domain/repositories/translation_repository.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/home.view.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/providers/translator.dart';
import 'package:go_translator/src/modules/setting/domain/entities/setting.entity.dart';
import 'package:go_translator/src/modules/setting/domain/repositories/setting.repo.dart';
import 'package:go_translator/src/theme/themes/dark/dark.theme.dart';
import 'package:go_translator/src/theme/themes/light/light.theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  late _FakeBookmarksRepository bookmarks;

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
        bookmarksRepositoryProvider.overrideWithValue(bookmarks = _FakeBookmarksRepository()),
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

  testWidgets('the translation card shows the target language plainly (no badge)', (tester) async {
    await pumpHome(tester);
    // Once in the language bar's target pill, once on top of the card.
    expect(find.text('French'), findsNWidgets(2));
    expect(find.text('FRENCH'), findsNothing);
    expect(find.text('On-device'), findsNothing);
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

  // Decision 2026-11-19: only the translator page has the drawer, so it has
  // no Translate tile.
  testWidgets('the drawer has no Translate tile; its destinations open on top', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'Go Translator',
      packageName: 'com.example.translator',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    await pumpHome(tester);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final drawer = find.byType(Drawer);
    expect(find.descendant(of: drawer, matching: find.text('Translate')), findsNothing);
    expect(find.descendant(of: drawer, matching: find.text('Offline Languages')), findsOneWidget);
    expect(find.descendant(of: drawer, matching: find.text('Bookmarks')), findsOneWidget);
    expect(find.descendant(of: drawer, matching: find.text('Settings')), findsOneWidget);
    expect(find.descendant(of: drawer, matching: find.text('3 installed')), findsOneWidget);
    expect(find.descendant(of: drawer, matching: find.text('0 saved')), findsOneWidget);
    expect(find.descendant(of: drawer, matching: find.text('Version 1.0.0')), findsOneWidget);

    await tester.tap(find.descendant(of: drawer, matching: find.text('Settings')));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
  });

  group('Bookmark saves the translation with the languages it was made in', () {
    Future<void> translateHello(WidgetTester tester) async {
      await pumpHome(tester);
      await tester.enterText(find.byType(EditableText).first, 'hello');
      await tester.pumpAndSettle(); // Translate is enabled from the next frame.
      await tester.tap(find.text('Translate'));
      await tester.pumpAndSettle();
      expect(state().translatedText, 'translated');
    }

    // The "Bookmarked" toast starts a 1 s timer in Fluttertoast; let it run
    // out so it doesn't outlive the test.
    Future<void> tapBookmark(WidgetTester tester) async {
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.star_outline));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
    }

    testWidgets('right after translating', (tester) async {
      await translateHello(tester);
      await tapBookmark(tester);

      final saved = bookmarks.saved.single;
      expect(saved.sourceText, 'hello');
      expect(saved.targetText, 'translated');
      expect(saved.sourceLanguageCode, 'en');
      expect(saved.targetLanguageCode, 'fr');
      expect(saved.savedAt, isNotNull);
    });

    testWidgets("after picking another target language, keeps the translation's languages", (tester) async {
      await translateHello(tester);
      await container.read(translatorProvider.notifier).setTargetLanguage('af');
      await tester.pumpAndSettle();
      await tapBookmark(tester);

      expect(bookmarks.saved.single.targetText, 'translated');
      expect(bookmarks.saved.single.targetLanguageCode, 'fr');
    });

    testWidgets('after editing the text, saves the text alone', (tester) async {
      await translateHello(tester);
      await tester.enterText(find.byType(EditableText).first, 'hello there');
      await tester.pumpAndSettle();
      await tapBookmark(tester);

      final saved = bookmarks.saved.single;
      expect(saved.sourceText, 'hello there');
      expect(saved.targetText, isNull);
      expect(saved.sourceLanguageCode, 'en');
      expect(saved.targetLanguageCode, isNull);
    });

    testWidgets('before translating, saves the text in the selected source language', (tester) async {
      await pumpHome(tester);
      await container.read(translatorProvider.notifier).setSourceLanguage('af');
      await tester.enterText(find.byType(EditableText).first, 'hallo');
      await tester.pumpAndSettle();
      await tapBookmark(tester);

      expect(bookmarks.saved.single.sourceLanguageCode, 'af');
      expect(bookmarks.saved.single.targetText, isNull);
    });
  });
}

final class _FakeBookmarksRepository implements BookmarksRepository {
  final saved = <BookmarkEntity>[];

  @override
  Future<List<BookmarkEntity>> getBookmarks() async => saved;

  @override
  Future<bool> containsSourceText(String sourceText) async => saved.any((b) => b.sourceText == sourceText);

  @override
  Future<void> save(BookmarkEntity bookmark) async => saved.add(bookmark);

  @override
  Future<void> remove(String id) async => saved.removeWhere((b) => b.id == id);
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
