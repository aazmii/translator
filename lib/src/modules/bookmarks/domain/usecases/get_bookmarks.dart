import '../../../../core/usecase/usecase.dart';
import '../entities/bookmark.entity.dart';
import '../repositories/bookmarks_repository.dart';

final class GetBookmarks
    implements UseCase<Future<List<BookmarkEntity>>, NoParams> {
  const GetBookmarks(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<List<BookmarkEntity>> call(NoParams params) =>
      _repository.getBookmarks();
}
