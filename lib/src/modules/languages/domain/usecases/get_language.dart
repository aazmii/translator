import '../../../../core/usecase/usecase.dart';
import '../entities/language.dart';
import '../repositories/offline_language_repository.dart';

/// Looks up one language by code, including whether its model is downloaded.
final class GetLanguage implements UseCase<Future<Language?>, String> {
  const GetLanguage(this._repository);

  final OfflineLanguageRepository _repository;

  @override
  Future<Language?> call(String code) => _repository.getLanguage(code);
}
