import '../../../../core/usecase/usecase.dart';
import '../entities/setting.entity.dart';
import '../repositories/setting.repo.dart';

/// Saves whether the keyboard opens when the home screen first opens.
final class SetKeyboardAtStartup implements UseCase<Future<AppSettings>, bool> {
  const SetKeyboardAtStartup(this._repository);

  final SettingsRepository _repository;

  @override
  Future<AppSettings> call(bool show) async {
    final settings = (await _repository.getSettings()).copyWith(showKeyboardAtStartup: show);
    await _repository.saveSettings(settings);
    return settings;
  }
}
