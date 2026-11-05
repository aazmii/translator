import '../../domain/entities/language.dart';

final class LanguageModel {
  const LanguageModel({
    required this.code,
    required this.name,
    required this.isDownloaded,
  });

  final String code;
  final String name;
  final bool isDownloaded;

  Language toEntity() =>
      Language(code: code, name: name, isDownloaded: isDownloaded);
}
