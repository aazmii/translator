import '../../../../core/usecase/usecase.dart';
import '../entities/bookmark.entity.dart';
import '../repositories/bookmarks_repository.dart';

typedef BookmarkIdFactory = String Function();
typedef BookmarkClock = DateTime Function();

final class SaveBookmarkParams {
  const SaveBookmarkParams({
    required this.sourceText,
    this.targetText,
    this.sourceLanguageCode,
    this.targetLanguageCode,
  });

  final String sourceText;
  final String? targetText;

  /// The language of [sourceText].
  final String? sourceLanguageCode;

  /// The language of [targetText]; ignored without a [targetText].
  final String? targetLanguageCode;
}

final class SaveBookmark implements UseCase<Future<bool>, SaveBookmarkParams> {
  SaveBookmark(
    this._repository, {
    BookmarkIdFactory? createId,
    BookmarkClock? now,
  }) : _createId =
           createId ?? (() => DateTime.now().microsecondsSinceEpoch.toString()),
       _now = now ?? DateTime.now;

  final BookmarksRepository _repository;
  final BookmarkIdFactory _createId;
  final BookmarkClock _now;

  @override
  Future<bool> call(SaveBookmarkParams params) async {
    final sourceText = params.sourceText.trim();
    if (sourceText.isEmpty) {
      throw ArgumentError.value(
        params.sourceText,
        'sourceText',
        'Cannot be empty',
      );
    }

    if (await _repository.containsSourceText(sourceText)) return false;

    final targetText = params.targetText?.trim();
    final hasTarget = targetText != null && targetText.isNotEmpty;
    await _repository.save(
      BookmarkEntity(
        id: _createId(),
        sourceText: sourceText,
        targetText: targetText,
        savedAt: _now(),
        sourceLanguageCode: params.sourceLanguageCode,
        targetLanguageCode: hasTarget ? params.targetLanguageCode : null,
      ),
    );
    return true;
  }
}
