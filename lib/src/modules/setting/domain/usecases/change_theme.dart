import '../../../../core/usecase/usecase.dart';
import '../entities/setting.entity.dart';
import '../entities/theme_profile.dart';
import '../repositories/setting.repo.dart';

final class ChangeTheme implements UseCase<Future<AppSettings>, ThemeProfile> {
  const ChangeTheme(this._repository);

  final SettingsRepository _repository;

  @override
  Future<AppSettings> call(ThemeProfile theme) async {
    final settings = (await _repository.getSettings()).copyWith(theme: theme);
    await _repository.saveSettings(settings);
    return settings;
  }
}
