import '../../domain/entities/setting.entity.dart';
import '../../domain/repositories/setting.repo.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/settings_model.dart';

final class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<AppSettings> getSettings() async {
    return (await _localDataSource.getSettings())?.toEntity() ??
        const AppSettings();
  }

  @override
  Future<void> saveSettings(AppSettings settings) {
    return _localDataSource.saveSettings(SettingsModel.fromEntity(settings));
  }
}
