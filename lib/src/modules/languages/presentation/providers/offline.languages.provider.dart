import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/core/usecase/usecase.dart';

import '../../domain/entities/language.dart';
import '../../domain/usecases/download_language.dart';

final offlineLanguagesProvider =
    AsyncNotifierProvider<OfflineLanguages, List<Language>>(
      OfflineLanguages.new,
    );

final class OfflineLanguages extends AsyncNotifier<List<Language>> {
  @override
  Future<List<Language>> build() async {
    return _loadLanguages();
  }

  Future<bool> deleteLanguage(String code) async {
    final deleted = await ref.read(deleteLanguageProvider)(code);
    if (deleted) state = AsyncData(await _loadLanguages());
    return deleted;
  }

  /// With [wifiOnly] (the default) the download waits for Wi-Fi.
  Future<bool> downloadLanguage(String code, {bool wifiOnly = true}) async {
    final downloaded = await ref.read(downloadLanguageProvider)(
      DownloadLanguageParams(code, wifiOnly: wifiOnly),
    );
    if (downloaded) state = AsyncData(await _loadLanguages());
    return downloaded;
  }

  Future<List<Language>> _loadLanguages() async {
    final languages = await ref.read(getOfflineLanguagesProvider)(
      const NoParams(),
    );
    return [
      ...languages.where((language) => language.isDownloaded),
      ...languages.where((language) => !language.isDownloaded),
    ];
  }
}
