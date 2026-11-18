import '../../../../core/usecase/usecase.dart';
import '../entities/bookmark.entity.dart';
import '../repositories/bookmarks_repository.dart';

/// Puts a deleted bookmark back exactly as it was (same id and saved time),
/// for Undo. Unlike SaveBookmark it creates nothing new.
final class RestoreBookmark implements UseCase<Future<void>, BookmarkEntity> {
  const RestoreBookmark(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<void> call(BookmarkEntity bookmark) => _repository.save(bookmark);
}
