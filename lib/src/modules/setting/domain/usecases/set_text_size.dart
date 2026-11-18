import '../../../../core/usecase/usecase.dart';
import '../entities/setting.entity.dart';
import '../repositories/setting.repo.dart';

/// Saves the font size of the source and translation text.
final class SetTextSize implements UseCase<Future<AppSettings>, double> {
  const SetTextSize(this._repository);

  final SettingsRepository _repository;

  @override
  Future<AppSettings> call(double size) async {
    final settings = (await _repository.getSettings()).copyWith(textSize: size);
    await _repository.saveSettings(settings);
    return settings;
  }
}
