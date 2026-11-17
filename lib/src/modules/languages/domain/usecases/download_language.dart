import '../../../../core/usecase/usecase.dart';
import '../repositories/offline_language_repository.dart';

final class DownloadLanguageParams {
  const DownloadLanguageParams(this.code, {this.wifiOnly = true});

  final String code;

  /// When true, the download waits for Wi-Fi.
  final bool wifiOnly;
}

final class DownloadLanguage
    implements UseCase<Future<bool>, DownloadLanguageParams> {
  const DownloadLanguage(this._repository);

  final OfflineLanguageRepository _repository;

  @override
  Future<bool> call(DownloadLanguageParams params) =>
      _repository.downloadLanguage(params.code, wifiOnly: params.wifiOnly);
}
