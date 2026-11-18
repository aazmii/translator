class BookmarkEntity {
  final String id;
  final String sourceText;
  final String? targetText;

  /// When it was saved. Null for bookmarks saved before this was stored.
  final DateTime? savedAt;

  /// The source text's language. Null for bookmarks saved before this was
  /// stored.
  final String? sourceLanguageCode;

  /// The translation's language. Null without a translation, and for
  /// bookmarks saved before this was stored.
  final String? targetLanguageCode;

  BookmarkEntity({
    required this.id,
    required this.sourceText,
    this.targetText,
    this.savedAt,
    this.sourceLanguageCode,
    this.targetLanguageCode,
  });
}
