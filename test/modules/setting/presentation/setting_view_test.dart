import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/modules/setting/data/models/settings_model.dart';
import 'package:go_translator/src/modules/setting/domain/entities/setting.entity.dart';
import 'package:go_translator/src/modules/setting/domain/entities/theme_profile.dart';
import 'package:go_translator/src/modules/setting/domain/repositories/setting.repo.dart';
import 'package:go_translator/src/modules/setting/presentation/view/setting_view.dart';

void main() {
  late _FakeSettingsRepository repository;

  Future<void> pumpSettings(WidgetTester tester, {AppSettings? settings}) async {
    repository = _FakeSettingsRepository(settings ?? const AppSettings());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: SettingView()),
      ),
    );
    await tester.pumpAndSettle();
  }

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

  testWidgets('Keyboard is ticked by default', (tester) async {
    await pumpSettings(tester);
    expect(find.text('Keyboard'), findsOneWidget);
    expect(find.text('Show the keyboard at startup'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('tapping the Keyboard row or its checkbox saves the change', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Keyboard'));
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
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();
    }

    testWidgets('the subtitle shows the size, 18 by default', (tester) async {
      await pumpSettings(tester);
      expect(find.text('18'), findsOneWidget);
    });

    testWidgets('turning the wheel resizes the preview', (tester) async {
      await pumpSettings(tester);
      await openDialog(tester);
      expect(previewSize(tester), 18);

      await turnWheel(tester, 2);
      expect(previewSize(tester), 22);
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
      expect(find.text('22'), findsOneWidget);
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
      expect(find.text('24'), findsOneWidget);
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
