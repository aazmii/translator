import '../../domain/entities/translation_settings.dart';
import '../../domain/repositories/translation_repository.dart';
import '../datasources/translation_local_data_source.dart';
import '../datasources/translation_service_data_source.dart';
import '../models/translation_settings_model.dart';

final class TranslationRepositoryImpl implements TranslationRepository {
  const TranslationRepositoryImpl(
    this._localDataSource,
    this._serviceDataSource,
  );

  final TranslationLocalDataSource _localDataSource;
  final TranslationServiceDataSource _serviceDataSource;

  @override
  Future<String> translate({
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String text,
  }) async {
    return _serviceDataSource.translate(
      sourceLanguageCode: sourceLanguageCode,
      targetLanguageCode: targetLanguageCode,
      text: text,
    );
  }

  @override
  Future<TranslationSettings?> getSettings() async {
    return (await _localDataSource.getSettings())?.toEntity();
  }

  @override
  Future<void> saveSettings(TranslationSettings settings) {
    return _localDataSource.saveSettings(
      TranslationSettingsModel.fromEntity(settings),
    );
  }
}
