import '../../domain/entities/bookmark.entity.dart';
import '../../domain/repositories/bookmarks.reopsitory.dart';
import '../datasource/bookmark.local.datasource.dart';
import '../model/bookmark.model.dart';

class BookmarksRepositoryImpl implements BookmarksRepository {
  final BookmarksLocalDataSource local;

  BookmarksRepositoryImpl(this.local);

  @override
  Future<List<BookmarkEntity>> getBookmarks() async {
    final models = await local.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> save(BookmarkEntity translationEntity) {
    return local.save(BookmarkModel.fromEntity(translationEntity));
  }

  @override
  Future<void> remove(String id) {
    return local.remove(id);
  }
}
