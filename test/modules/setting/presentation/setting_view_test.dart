import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/modules/setting/data/models/settings_model.dart';
import 'package:go_translator/src/modules/setting/domain/entities/setting.entity.dart';
import 'package:go_translator/src/modules/setting/domain/entities/theme_profile.dart';
import 'package:go_translator/src/modules/setting/domain/repositories/setting.repo.dart';
import 'package:go_translator/src/modules/setting/presentation/view/setting_view.dart';
import 'package:go_translator/src/theme/themes/dark/dark.theme.dart';
import 'package:go_translator/src/theme/themes/light/light.theme.dart';
import 'package:go_translator/src/modules/bookmarks/domain/entities/bookmark.entity.dart';
import 'package:go_translator/src/modules/bookmarks/domain/repositories/bookmarks_repository.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation_settings.dart';
import 'package:go_translator/src/modules/home/domain/repositories/translation_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../helpers/fake_offline_language_repository.dart';

void main() {
  late _FakeSettingsRepository repository;

  setUpAll(() async {
    // Real Inter widths, so the 320px overflow checks match the phone.
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

  Future<void> pumpSettings(WidgetTester tester, {AppSettings? settings, ThemeData? theme}) async {
    repository = _FakeSettingsRepository(settings ?? const AppSettings());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(theme: theme ?? lightTheme, home: const SettingView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('layout (Stitch settings screen)', () {
    testWidgets('PREFERENCES and ABOUT sections with their tiles', (tester) async {
      await pumpSettings(tester);
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Show the keyboard at startup'), findsOneWidget);
      expect(find.text('Automatically focus text input when app opens'), findsOneWidget);
      expect(find.text('Translation text size'), findsOneWidget);
      expect(find.text('App version'), findsOneWidget);
      expect(find.text('Open source licences'), findsOneWidget);
    });

    testWidgets('the version tile shows the installed version', (tester) async {
      await pumpSettings(tester);
      expect(find.text('Go Translator 1.0.0'), findsOneWidget);
    });

    testWidgets('Open source licences opens the licences page', (tester) async {
      await pumpSettings(tester);
      await tester.tap(find.text('Open source licences'));
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
    });

    testWidgets('nothing shows what the app does not have', (tester) async {
      await pumpSettings(tester);
      for (final text in ['Clear cache', 'Engine Ready', 'Latest', '100% Private']) {
        expect(find.textContaining(text), findsNothing, reason: text);
      }
    });

    for (final (name, theme) in [('light', lightTheme), ('dark', darkTheme)]) {
      testWidgets('no overflow on a 320px phone in $name mode, including both dialogs', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await pumpSettings(tester, theme: theme);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Theme'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Translation text size'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('the theme dialog describes each option', (tester) async {
      await pumpSettings(tester);
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      expect(find.text('Choose theme'), findsOneWidget);
      expect(find.text('Follow system defaults'), findsOneWidget);
      expect(find.text('Standard high clarity view'), findsOneWidget);
      expect(find.text('Deep contrast for night use'), findsOneWidget);
    });
  });

  testWidgets('new installs show Device theme', (tester) async {
    await pumpSettings(tester);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Device theme'), findsOneWidget);
  });

  testWidgets('the subtitle shows the saved theme', (tester) async {
    await pumpSettings(tester, settings: const AppSettings(theme: ThemeProfile.dark));
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('tapping a theme saves it, closes the dialog and updates the subtitle', (tester) async {
    await pumpSettings(tester);
    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();

    expect(find.byType(ThemeDialog), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    expect(find.byType(ThemeDialog), findsNothing);
    expect(repository.settings.theme, ThemeProfile.light);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Device theme'), findsNothing);
  });

  testWidgets('Cancel closes the dialog without saving', (tester) async {
    await pumpSettings(tester, settings: const AppSettings(theme: ThemeProfile.dark));
    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(ThemeDialog), findsNothing);
    expect(repository.saves, 0);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('the keyboard tile is ticked by default', (tester) async {
    await pumpSettings(tester);
    expect(find.text('Show the keyboard at startup'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('tapping the Keyboard row or its checkbox saves the change', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Show the keyboard at startup'));
    await tester.pumpAndSettle();
    expect(repository.settings.showKeyboardAtStartup, isFalse);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(repository.settings.showKeyboardAtStartup, isTrue);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('changing the theme keeps the keyboard setting', (tester) async {
    await pumpSettings(tester, settings: const AppSettings(showKeyboardAtStartup: false));
    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(repository.settings.theme, ThemeProfile.dark);
    expect(repository.settings.showKeyboardAtStartup, isFalse);
  });

  test('the keyboard setting saves and loads; older settings default to show', () {
    for (final show in [true, false]) {
      final json = SettingsModel.fromEntity(AppSettings(showKeyboardAtStartup: show)).toJson();
      expect(SettingsModel.fromJson(json).showKeyboardAtStartup, show);
    }
    expect(SettingsModel.fromJson('{"firstRun":false,"theme":"dark"}').showKeyboardAtStartup, isTrue);
  });

  group('Text size', () {
    double previewSize(WidgetTester tester) => tester
        .widget<Text>(find.descendant(of: find.byKey(const Key('textSizePreview')), matching: find.byType(Text)))
        .style!
        .fontSize!;

    /// Turns the wheel by [steps] sizes (positive = larger).
    Future<void> turnWheel(WidgetTester tester, int steps) async {
      await tester.drag(find.byType(ListWheelScrollView), Offset(0, -44.0 * steps));
      await tester.pumpAndSettle();
    }

    Future<void> openDialog(WidgetTester tester) async {
      await tester.tap(find.text('Translation text size'));
      await tester.pumpAndSettle();
    }

    testWidgets('the subtitle shows the size, 18 by default', (tester) async {
      await pumpSettings(tester);
      expect(find.text('18 sp'), findsOneWidget);
    });

    testWidgets('turning the wheel resizes the preview', (tester) async {
      await pumpSettings(tester);
      await openDialog(tester);
      expect(previewSize(tester), 18);

      await turnWheel(tester, 2);
      expect(previewSize(tester), 22);
      expect(
        find.descendant(of: find.byKey(const Key('textSizeBadge')), matching: find.text('22 sp')),
        findsOneWidget,
      );
      expect(find.text('Changes translation text size only. System UI will remain standard.'), findsOneWidget);
      expect(repository.saves, 0, reason: 'nothing is saved while the dialog is open');
    });

    testWidgets('tapping outside closes and saves the picked size', (tester) async {
      await pumpSettings(tester);
      await openDialog(tester);
      await turnWheel(tester, 2);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.byType(ListWheelScrollView), findsNothing);
      expect(repository.settings.textSize, 22);
      expect(find.text('22 sp'), findsOneWidget);
    });

    testWidgets('Back closes and saves the picked size', (tester) async {
      await pumpSettings(tester);
      await openDialog(tester);
      await turnWheel(tester, -1);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(ListWheelScrollView), findsNothing);
      expect(repository.settings.textSize, 16);
    });

    testWidgets('Cancel keeps the old size', (tester) async {
      await pumpSettings(tester, settings: const AppSettings(textSize: 24));
      await openDialog(tester);
      expect(previewSize(tester), 24);
      await turnWheel(tester, 2);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(ListWheelScrollView), findsNothing);
      expect(repository.saves, 0);
      expect(find.text('24 sp'), findsOneWidget);
    });

    test('saves and loads; missing or odd values load as 18', () {
      for (final size in AppSettings.textSizes) {
        final json = SettingsModel.fromEntity(AppSettings(textSize: size)).toJson();
        expect(SettingsModel.fromJson(json).textSize, size);
      }
      expect(SettingsModel.fromJson('{"firstRun":false,"theme":"dark"}').textSize, 18);
      expect(SettingsModel.fromJson('{"textSize":17}').textSize, 18);
      expect(SettingsModel.fromJson('{"textSize":"big"}').textSize, 18);
    });
  });

  test('a saved theme, including system, loads back', () {
    for (final theme in ThemeProfile.values) {
      final json = SettingsModel.fromEntity(AppSettings(theme: theme)).toJson();
      expect(SettingsModel.fromJson(json).theme, theme);
    }
  });

  test('themes saved before this change still load', () {
    expect(SettingsModel.fromJson('{"firstRun":false,"theme":"light"}').theme, ThemeProfile.light);
    expect(SettingsModel.fromJson('{"firstRun":false,"theme":"dark"}').theme, ThemeProfile.dark);
  });

  testWidgets('the drawer on Settings highlights Settings; Translate goes back to the first page', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(_FakeSettingsRepository(const AppSettings())),
          translationRepositoryProvider.overrideWithValue(_FakeTranslationRepository()),
          offlineLanguageRepositoryProvider.overrideWithValue(FakeOfflineLanguageRepository()),
          bookmarksRepositoryProvider.overrideWithValue(_FakeBookmarksRepository()),
        ],
        // Stands in for the translator page, with Settings pushed on top.
        child: MaterialApp(
          theme: lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SettingView())),
                child: const Text('first page'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('first page'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final drawer = find.byType(Drawer);
    // The highlighted tile is the one with the arrow; it must be Settings.
    final highlighted = find.ancestor(of: find.byIcon(Icons.arrow_forward_ios), matching: find.byType(InkWell));
    expect(find.descendant(of: highlighted, matching: find.text('Settings')), findsOneWidget);
    expect(find.descendant(of: highlighted, matching: find.text('Translate')), findsNothing);
    // Real counts in the badges: the fake has 3 downloaded languages, 0 bookmarks.
    expect(find.descendant(of: drawer, matching: find.text('3 installed')), findsOneWidget);
    expect(find.descendant(of: drawer, matching: find.text('0 saved')), findsOneWidget);

    await tester.tap(find.descendant(of: drawer, matching: find.text('Translate')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingView), findsNothing);
    expect(find.text('first page'), findsOneWidget);
  });
}

final class _FakeTranslationRepository implements TranslationRepository {
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
  }) async => 'translated';
}

final class _FakeBookmarksRepository implements BookmarksRepository {
  @override
  Future<List<BookmarkEntity>> getBookmarks() async => const [];

  @override
  Future<bool> containsSourceText(String sourceText) async => false;

  @override
  Future<void> save(BookmarkEntity bookmark) async {}

  @override
  Future<void> remove(String id) async {}
}

final class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.settings);

  AppSettings settings;
  int saves = 0;

  @override
  Future<AppSettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    saves++;
    this.settings = settings;
  }
}
