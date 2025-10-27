import 'package:go_translator/src/core/usecase/usecase.dart';
import 'package:go_translator/src/core/domain/entities/language.entity.dart';

import '../repository/offline.translation.reopsitory.dart';

class GetOfflineLanguageUseCase implements AsyncUseCase<List<LanguageEntity>, void> {
  final OfflineLanguageRepository _translationRepository;

  GetOfflineLanguageUseCase(this._translationRepository);

  @override
  Future<List<LanguageEntity>> call({void p}) {
    return _translationRepository.getAvailableLanguages();
  }
}
