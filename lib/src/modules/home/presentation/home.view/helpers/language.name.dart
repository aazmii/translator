import 'package:go_translator/src/core/extensions/extensions.dart';
import 'package:go_translator/src/modules/languages/domain/entities/language.dart';

/// The display name for a language [code], e.g. "English"; the code itself
/// when the language isn't in [languages], and '' for no code.
String languageName(List<Language> languages, String? code) {
  if (code == null || code.isEmpty) return '';
  final language = languages.cast<Language?>().firstWhere(
    (language) => language?.code == code,
    orElse: () => null,
  );
  return (language?.name ?? code).capitalize;
}
