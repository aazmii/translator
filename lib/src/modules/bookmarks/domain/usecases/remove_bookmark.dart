import '../../../../core/usecase/usecase.dart';
import '../repositories/bookmarks_repository.dart';

final class RemoveBookmark implements UseCase<Future<void>, String> {
  const RemoveBookmark(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<void> call(String id) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'Cannot be empty');
    return _repository.remove(id);
  }
}
