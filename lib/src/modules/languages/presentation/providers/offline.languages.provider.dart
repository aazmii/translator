import 'package:go_translator/src/core/di/providers.dart';
import 'package:go_translator/src/core/domain/entities/language.entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repository/offline.translation.reopsitory.dart';
part 'offline.languages.provider.g.dart';

@riverpod
class OfflineLanguages extends _$OfflineLanguages {
  late OfflineLanguageRepository _repo;
  late List<LanguageEntity> languageList;
  @override
  Future<List<LanguageEntity>> build() async {
    _repo = ref.read(offlineLanguageRepositoryProvider);
    final getLanguages = ref.read(getOfflineLanguageUseCaseProvider);
    languageList = await getLanguages();
    final sorted = [...languageList.where((l) => l.isDownloaded), ...languageList.where((l) => !l.isDownloaded)];
    return sorted;
  }

  Future<bool> deleteLanguage(String code) async {
    return await _repo.deleteLanguage(code);
  }

  Future<bool> downloadLanguage(String code) async {
    return await _repo.downloadLanguage(code);
  }
}
