import '../../../../core/usecase/usecase.dart';
import '../entities/translation_settings.dart';
import '../repositories/translation_repository.dart';

final class SaveTranslationSettings
    implements UseCase<Future<void>, TranslationSettings> {
  const SaveTranslationSettings(this._repository);

  final TranslationRepository _repository;

  @override
  Future<void> call(TranslationSettings settings) =>
      _repository.saveSettings(settings);
}
