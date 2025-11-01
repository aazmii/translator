import 'package:go_translator/src/core/domain/entities/language.entity.dart';
import 'package:go_translator/src/modules/languages/data/repository/offline.lang.repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repository/offline.translation.reopsitory.dart';
part 'offline.languages.provider.g.dart';

//TODO: instead of [OfflineLanguageRepository] use usecases
@riverpod
class OfflineLanguages extends _$OfflineLanguages {
  late OfflineLanguageRepository _repo;
  late List<LanguageEntity> languageList;
  @override
  Future<List<LanguageEntity>> build() async {
    _repo = OfflineLanguageRepositoryImpl();
    languageList = await _repo.getAvailableLanguages();
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
