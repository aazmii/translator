import '../model/bookmark.model.dart';

abstract class BookmarksLocalDataSource {
  Future<List<BookmarkModel>> getAll();
  Future<bool> containsSourceText(String sourceText);
  Future<void> save(BookmarkModel model);
  Future<void> remove(String id);
}
