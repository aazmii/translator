import '../../../../core/usecase/usecase.dart';
import '../entities/bookmark.entity.dart';
import '../repositories/bookmarks_repository.dart';

typedef BookmarkIdFactory = String Function();

final class SaveBookmarkParams {
  const SaveBookmarkParams({required this.sourceText, this.targetText});

  final String sourceText;
  final String? targetText;
}

final class SaveBookmark implements UseCase<Future<bool>, SaveBookmarkParams> {
  SaveBookmark(this._repository, {BookmarkIdFactory? createId})
    : _createId =
          createId ?? (() => DateTime.now().microsecondsSinceEpoch.toString());

  final BookmarksRepository _repository;
  final BookmarkIdFactory _createId;

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

    await _repository.save(
      BookmarkEntity(
        id: _createId(),
        sourceText: sourceText,
        targetText: params.targetText?.trim(),
      ),
    );
    return true;
  }
}
