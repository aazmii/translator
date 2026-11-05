import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/modules/setting/domain/entities/setting.entity.dart';
import 'package:go_translator/src/modules/setting/domain/entities/theme_profile.dart';
import 'package:go_translator/src/modules/setting/domain/repositories/setting.repo.dart';
import 'package:go_translator/src/modules/setting/domain/usecases/change_theme.dart';

void main() {
  test('ChangeTheme persists and returns updated settings', () async {
    final repository = _FakeSettingsRepository();
    final changeTheme = ChangeTheme(repository);

    final result = await changeTheme(ThemeProfile.dark);

    expect(result.theme, ThemeProfile.dark);
    expect(repository.settings.theme, ThemeProfile.dark);
  });
}

final class _FakeSettingsRepository implements SettingsRepository {
  AppSettings settings = const AppSettings();

  @override
  Future<AppSettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    this.settings = settings;
  }
}
