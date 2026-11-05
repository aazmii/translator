import '../../../../core/usecase/usecase.dart';
import '../entities/translation_settings.dart';
import '../repositories/translation_repository.dart';

final class GetTranslationSettings
    implements UseCase<Future<TranslationSettings?>, NoParams> {
  const GetTranslationSettings(this._repository);

  final TranslationRepository _repository;

  @override
  Future<TranslationSettings?> call(NoParams params) =>
      _repository.getSettings();
}
