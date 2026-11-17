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

  @override
  Future<bool> downloadLanguage(String code) async => notDownloaded.remove(code);

  @override
  Future<bool> deleteLanguage(String code) async => notDownloaded.add(code);
}
