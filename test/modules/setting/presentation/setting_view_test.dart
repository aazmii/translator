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
