import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/core/widgets/app_mark.dart';
import 'package:go_translator/src/modules/bookmarks/domain/entities/bookmark.entity.dart';
import 'package:go_translator/src/modules/bookmarks/domain/repositories/bookmarks_repository.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation_settings.dart';
import 'package:go_translator/src/modules/home/domain/repositories/translation_repository.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/card.surface.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/home.drawer/home.drawer.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/source.card/souce.card.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/target.card/target.card.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/home.view.dart';
import 'package:go_translator/src/modules/setting/domain/entities/setting.entity.dart';
import 'package:go_translator/src/modules/setting/domain/repositories/setting.repo.dart';
import 'package:go_translator/src/theme/themes/dark/dark.theme.dart';
import 'package:go_translator/src/theme/themes/light/light.theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../helpers/fake_offline_language_repository.dart';

const _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');

/// The translation card (2026-11-19): plain and identical to the source card,
/// with the target language's name on top and a Save pill.
void main() {
  late _FakeBookmarksRepository bookmarks;

  setUpAll(() async {
    final loader = FontLoader('Inter');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/fonts/Inter-$weight.ttf'));
    }
    await loader.load();
    PackageInfo.setMockInitialValues(
      appName: 'Go Translator',
      packageName: 'com.example.translator',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _toastChannel,
      (_) async => true,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_toastChannel, null);
  });

  Future<void> pumpHome(WidgetTester tester, {ThemeData? theme, Size size = const Size(390, 844)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          translationRepositoryProvider.overrideWithValue(_FakeTranslationRepository()),
          offlineLanguageRepositoryProvider.overrideWithValue(FakeOfflineLanguageRepository()),
          settingsRepositoryProvider.overrideWithValue(_FakeSettingsRepository()),
          bookmarksRepositoryProvider.overrideWithValue(bookmarks = _FakeBookmarksRepository()),
        ],
        child: MaterialApp(theme: theme ?? lightTheme, home: const HomeView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder inCard(Finder finder) => find.descendant(of: find.byType(TargetCard), matching: finder);
  Finder save() => inCard(find.widgetWithText(TextButton, 'Save'));

  Future<void> translateHello(WidgetTester tester) async {
    await tester.enterText(find.byType(EditableText).first, 'hello');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Translate'));
    await tester.pumpAndSettle();
  }

  testWidgets('Save is a 36px pill, disabled until there is a translation', (tester) async {
    await pumpHome(tester);
    expect(save(), findsOneWidget);
    expect(tester.getSize(save()).height, 36);
    expect(tester.widget<TextButton>(save()).onPressed, isNull);

    await translateHello(tester);
    expect(tester.widget<TextButton>(save()).onPressed, isNotNull);
  });

  testWidgets('Save bookmarks the text, the translation and their languages', (tester) async {
    await pumpHome(tester);
    await translateHello(tester);

    await tester.tap(save());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2)); // let the toast timer end

    final saved = bookmarks.saved.single;
    expect(saved.sourceText, 'hello');
    expect(saved.targetText, 'translated');
    expect(saved.sourceLanguageCode, 'en');
    expect(saved.targetLanguageCode, 'fr');
  });

  testWidgets('Save and the star save the same bookmark (no duplicate)', (tester) async {
    await pumpHome(tester);
    await translateHello(tester);
    await tester.tap(save());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.star_outline));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(bookmarks.saved, hasLength(1));
  });

  testWidgets('no star in the translation card', (tester) async {
    await pumpHome(tester);
    expect(inCard(find.byIcon(Icons.star_outline)), findsNothing);
  });

  testWidgets('plain like the source card: same surface, size, text style and plain tool buttons', (tester) async {
    await pumpHome(tester);
    await translateHello(tester);
    Finder surfaceOf(Type card) => find.descendant(of: find.byType(card), matching: find.byType(CardSurface)).first;
    expect(tester.widget<CardSurface>(surfaceOf(TargetCard)).color,
        tester.widget<CardSurface>(surfaceOf(SourceCard)).color);
    expect(tester.getSize(find.byType(TargetCard)), tester.getSize(find.byType(SourceCard)));

    final source = find.descendant(of: find.byType(SourceCard), matching: find.byType(EditableText));
    final target = inCard(find.byType(EditableText));
    expect(tester.widget<EditableText>(target).style, tester.widget<EditableText>(source).style);
    expect(tester.getSize(target), tester.getSize(source), reason: 'text areas line up');
    expect(tester.getRect(target).left - tester.getRect(find.byType(TargetCard)).left,
        tester.getRect(source).left - tester.getRect(find.byType(SourceCard)).left);

    for (final tooltip in ['Listen', 'Copy', 'Share']) {
      final button = find.ancestor(of: inCard(find.byTooltip(tooltip)), matching: find.byType(IconButton));
      expect(tester.getSize(button), const Size(40, 40), reason: tooltip);
      expect(tester.widget<IconButton>(button).style?.backgroundColor, isNull, reason: '$tooltip has no tint');
    }
  });

  testWidgets('no decoration: plain language name, no badge, no glow', (tester) async {
    await pumpHome(tester);
    expect(inCard(find.text('French')), findsOneWidget);
    expect(find.text('FRENCH'), findsNothing);
    expect(find.text('On-device'), findsNothing);
    expect(find.byKey(const Key('targetCardGlow')), findsNothing);
    expect(inCard(find.byType(ImageFiltered)), findsNothing);
  });

  for (final (name, theme) in [('light', lightTheme), ('dark', darkTheme)]) {
    for (final size in [const Size(320, 568), const Size(390, 844)]) {
      testWidgets('no overflow at ${size.width.toInt()}px in $name mode, with a translation', (tester) async {
        await pumpHome(tester, theme: theme, size: size);
        await translateHello(tester);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the drawer header shows the shared app mark', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(HomeDrawer), matching: find.byType(AppMark)), findsOneWidget);
    expect(find.byIcon(Icons.g_translate), findsNothing);
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
