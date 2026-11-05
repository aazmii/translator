import '../../../../core/usecase/usecase.dart';
import '../entities/language.dart';
import '../repositories/offline_language_repository.dart';

final class GetOfflineLanguages
    implements UseCase<Future<List<Language>>, NoParams> {
  const GetOfflineLanguages(this._repository);

  final OfflineLanguageRepository _repository;

  @override
  Future<List<Language>> call(NoParams params) =>
      _repository.getAvailableLanguages();
}
