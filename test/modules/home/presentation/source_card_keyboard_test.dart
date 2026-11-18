import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation_settings.dart';
import 'package:go_translator/src/modules/home/domain/repositories/translation_repository.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/source.card/souce.card.dart';
import 'package:go_translator/src/modules/setting/domain/entities/setting.entity.dart';
import 'package:go_translator/src/modules/setting/domain/repositories/setting.repo.dart';

import '../../../helpers/fake_offline_language_repository.dart';

void main() {
  Future<bool> sourceFocusedAtStartup(WidgetTester tester, SettingsRepository settings) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settings),
          translationRepositoryProvider.overrideWithValue(_FakeTranslationRepository()),
          offlineLanguageRepositoryProvider.overrideWithValue(FakeOfflineLanguageRepository()),
        ],
        child: const MaterialApp(home: Scaffold(body: SourceCard())),
      ),
    );
    await tester.pumpAndSettle();
    final field = tester.widget<EditableText>(find.byType(EditableText));
    return field.focusNode.hasFocus;
  }

  testWidgets('focuses the source field by default', (tester) async {
    expect(await sourceFocusedAtStartup(tester, _FakeSettingsRepository(const AppSettings())), isTrue);
  });

  testWidgets('does not focus it when turned off in Settings', (tester) async {
    final settings = _FakeSettingsRepository(const AppSettings(showKeyboardAtStartup: false));
    expect(await sourceFocusedAtStartup(tester, settings), isFalse);
  });

  testWidgets('focuses it when the settings fail to load', (tester) async {
    expect(await sourceFocusedAtStartup(tester, _FailingSettingsRepository()), isTrue);
  });
}

final class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.settings);

  AppSettings settings;

  @override
  Future<AppSettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(AppSettings settings) async => this.settings = settings;
}

final class _FailingSettingsRepository implements SettingsRepository {
  @override
  Future<AppSettings> getSettings() async => throw StateError('storage unavailable');

  @override
  Future<void> saveSettings(AppSettings settings) async {}
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
