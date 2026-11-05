import '../entities/bookmark.entity.dart';

abstract interface class BookmarksRepository {
  Future<List<BookmarkEntity>> getBookmarks();
  Future<bool> containsSourceText(String sourceText);
  Future<void> save(BookmarkEntity bookmark);
  Future<void> remove(String id);
}
