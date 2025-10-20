import 'package:translator/src/core/usecase/usecase.dart';
import 'package:translator/src/modules/home/domain/entities/language.entity.dart';
import 'package:translator/src/modules/home/domain/repositories/translation.repository.dart';

class GetLanguageUseCase implements AsyncUseCase<List<LanguageEntity>, void> {
  final TranslationRepository _translationRepository;

  GetLanguageUseCase(this._translationRepository);

  @override
  Future<List<LanguageEntity>> call({void p}) {
    return _translationRepository.getAvailableLanguages();
  }
}
