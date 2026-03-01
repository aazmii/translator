class BookmarkEntity {
  final String id;
  final String sourceText;
  final String? targetText;
  BookmarkEntity({required this.id, required this.sourceText, this.targetText});
}
