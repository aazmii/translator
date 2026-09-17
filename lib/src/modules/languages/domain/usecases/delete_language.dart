import '../../../../core/usecase/usecase.dart';
import '../repositories/offline_language_repository.dart';

final class DeleteLanguage implements UseCase<Future<bool>, String> {
  const DeleteLanguage(this._repository);

  final OfflineLanguageRepository _repository;

  @override
  Future<bool> call(String code) => _repository.deleteLanguage(code);
}
