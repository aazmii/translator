final class Language {
  const Language({
    required this.code,
    required this.name,
    required this.isDownloaded,
  });

  final String code;
  final String name;
  final bool isDownloaded;

  Language copyWith({bool? isDownloaded}) => Language(
    code: code,
    name: name,
    isDownloaded: isDownloaded ?? this.isDownloaded,
  );
}
