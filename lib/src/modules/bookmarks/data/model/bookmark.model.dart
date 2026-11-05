import '../../domain/entities/bookmark.entity.dart';

class BookmarkModel {
  final String id;
  final String sourceText;
  final String? targetText;

  BookmarkModel({required this.id, required this.sourceText, this.targetText});

  BookmarkEntity toEntity() =>
      BookmarkEntity(id: id, sourceText: sourceText, targetText: targetText);

  Map<String, dynamic> toMap() => {
    'id': id,
    'sourceText': sourceText,
    'targetText': targetText,
  };

  factory BookmarkModel.fromMap(Map<String, dynamic> map) => BookmarkModel(
    id: map['id'] as String,
    sourceText: map['sourceText'] as String,
    targetText: map['targetText'] as String?,
  );

  factory BookmarkModel.fromEntity(BookmarkEntity e) => BookmarkModel(
    id: e.id,
    sourceText: e.sourceText,
    targetText: e.targetText,
  );
}
