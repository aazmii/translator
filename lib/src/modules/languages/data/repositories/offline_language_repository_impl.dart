import '../../domain/entities/language.dart';
import '../../domain/repositories/offline_language_repository.dart';
import '../datasources/language_model_data_source.dart';

final class OfflineLanguageRepositoryImpl implements OfflineLanguageRepository {
  const OfflineLanguageRepositoryImpl(this._dataSource);

  final LanguageModelDataSource _dataSource;

  @override
  Future<List<Language>> getAvailableLanguages() async {
    final models = await _dataSource.getLanguages();
    return models.map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Future<Language?> getLanguage(String code) async =>
      (await _dataSource.getLanguage(code))?.toEntity();

  @override
  Future<bool> downloadLanguage(String code, {bool wifiOnly = true}) =>
      _dataSource.download(code, wifiOnly: wifiOnly);

  @override
  Future<bool> deleteLanguage(String code) => _dataSource.delete(code);
}
