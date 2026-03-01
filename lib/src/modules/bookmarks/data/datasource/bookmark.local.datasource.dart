import '../model/bookmark.model.dart';

abstract class BookmarksLocalDataSource {
  Future<List<BookmarkModel>> getAll();
  Future<void> save(BookmarkModel model);
  Future<void> remove(String id);
}
