import '../../../../core/usecase/usecase.dart';
import '../repositories/offline_language_repository.dart';

final class DownloadLanguage implements UseCase<Future<bool>, String> {
  const DownloadLanguage(this._repository);

  final OfflineLanguageRepository _repository;

  @override
  Future<bool> call(String code) => _repository.downloadLanguage(code);
}
