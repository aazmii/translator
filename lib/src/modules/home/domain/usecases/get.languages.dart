import 'package:go_translator/src/core/usecase/usecase.dart';
import 'package:go_translator/src/modules/home/domain/entities/language.entity.dart';
import 'package:go_translator/src/modules/home/domain/repositories/translation.repository.dart';

class GetOfflineLanguageUseCase implements AsyncUseCase<List<LanguageEntity>, void> {
  final OfflineTranslationRepository _translationRepository;

  GetOfflineLanguageUseCase(this._translationRepository);

  @override
  Future<List<LanguageEntity>> call({void p}) {
    return _translationRepository.getAvailableLanguages();
  }
}
