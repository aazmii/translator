import 'dart:async';

import 'package:go_translator/src/modules/languages/domain/entities/language.dart';
import 'package:go_translator/src/modules/languages/domain/repositories/offline_language_repository.dart';

/// Knows English, French and Afrikaans. Every language is downloaded unless
/// its code is in [notDownloaded].
final class FakeOfflineLanguageRepository implements OfflineLanguageRepository {
  final Set<String> notDownloaded = {};

  static const _names = {'en': 'english', 'fr': 'french', 'af': 'afrikaans'};

  @override
  Future<Language?> getLanguage(String code) async {
    final name = _names[code];
    if (name == null) return null;
    return Language(code: code, name: name, isDownloaded: !notDownloaded.contains(code));
  }

  @override
  Future<List<Language>> getAvailableLanguages() async => [
    for (final code in _names.keys) (await getLanguage(code))!,
  ];

  /// The arguments of each download call, in order.
  final List<({String code, bool wifiOnly})> downloads = [];

  /// When set, downloads wait for this instead of finishing at once. Complete
  /// it with true to mark the language downloaded, false to fail.
  Completer<bool>? pendingDownload;

  @override
  Future<bool> downloadLanguage(String code, {bool wifiOnly = true}) async {
    downloads.add((code: code, wifiOnly: wifiOnly));
    final ok = await (pendingDownload?.future ?? Future.value(true));
    if (ok) notDownloaded.remove(code);
    return ok;
  }

  /// The code of each delete call, in order.
  final List<String> deletes = [];

  /// When true, deletes report failure and change nothing.
  bool failDeletes = false;

  @override
  Future<bool> deleteLanguage(String code) async {
    deletes.add(code);
    if (failDeletes) return false;
    return notDownloaded.add(code);
  }
}
