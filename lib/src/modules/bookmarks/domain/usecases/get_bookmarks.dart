import '../../../../core/usecase/usecase.dart';
import '../entities/bookmark.entity.dart';
import '../repositories/bookmarks_repository.dart';

/// All bookmarks, newest first by saved time. Bookmarks saved before the time
/// was stored come after the dated ones, in the repository's order.
final class GetBookmarks
    implements UseCase<Future<List<BookmarkEntity>>, NoParams> {
  const GetBookmarks(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<List<BookmarkEntity>> call(NoParams params) async {
    final all = await _repository.getBookmarks();
    final dated = all.where((b) => b.savedAt != null).toList()
      ..sort((a, b) => b.savedAt!.compareTo(a.savedAt!));
    return [...dated, ...all.where((b) => b.savedAt == null)];
  }
}
