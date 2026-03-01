import '../entities/bookmark.entity.dart';

abstract class BookmarksRepository {
  Future<List<BookmarkEntity>> getBookmarks();
  Future<void> save(BookmarkEntity translationEntity);
  Future<void> remove(String id);
}
