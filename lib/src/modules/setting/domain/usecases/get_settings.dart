import '../../../../core/usecase/usecase.dart';
import '../entities/setting.entity.dart';
import '../repositories/setting.repo.dart';

final class GetSettings implements UseCase<Future<AppSettings>, NoParams> {
  const GetSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Future<AppSettings> call(NoParams params) => _repository.getSettings();
}
