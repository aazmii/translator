import '../../domain/entities/bookmark.entity.dart';

class BookmarkModel {
  final String id;
  final String sourceText;
  final String? targetText;
  final DateTime? savedAt;
  final String? sourceLanguageCode;
  final String? targetLanguageCode;

  BookmarkModel({
    required this.id,
    required this.sourceText,
    this.targetText,
    this.savedAt,
    this.sourceLanguageCode,
    this.targetLanguageCode,
  });

  BookmarkEntity toEntity() => BookmarkEntity(
    id: id,
    sourceText: sourceText,
    targetText: targetText,
    savedAt: savedAt,
    sourceLanguageCode: sourceLanguageCode,
    targetLanguageCode: targetLanguageCode,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'sourceText': sourceText,
    'targetText': targetText,
    'savedAt': savedAt?.toUtc().toIso8601String(),
    'sourceLanguageCode': sourceLanguageCode,
    'targetLanguageCode': targetLanguageCode,
  };

  /// Bookmarks saved before savedAt and the language codes existed have no
  /// such keys; those, and unreadable values, load as null.
  factory BookmarkModel.fromMap(Map<String, dynamic> map) => BookmarkModel(
    id: map['id'] as String,
    sourceText: map['sourceText'] as String,
    targetText: map['targetText'] as String?,
    savedAt: _date(map['savedAt']),
    sourceLanguageCode: _code(map['sourceLanguageCode']),
    targetLanguageCode: _code(map['targetLanguageCode']),
  );

  factory BookmarkModel.fromEntity(BookmarkEntity e) => BookmarkModel(
    id: e.id,
    sourceText: e.sourceText,
    targetText: e.targetText,
    savedAt: e.savedAt,
    sourceLanguageCode: e.sourceLanguageCode,
    targetLanguageCode: e.targetLanguageCode,
  );

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;

  static String? _code(Object? value) =>
      value is String && value.isNotEmpty ? value : null;
}
