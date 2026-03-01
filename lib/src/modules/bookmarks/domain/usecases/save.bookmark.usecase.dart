import 'package:go_translator/src/core/usecase/usecase.dart';
import 'package:go_translator/src/modules/bookmarks/domain/entities/bookmark.entity.dart';

import '../repositories/bookmarks.reopsitory.dart';

class SaveBookmarkUsecase implements AsyncUseCase<void, BookmarkEntity> {
  final BookmarksRepository bookmarksRepository;

  SaveBookmarkUsecase(this.bookmarksRepository);

  @override
  Future<void> call({BookmarkEntity? p}) {
    if (p == null) {
      throw ArgumentError.notNull('p');
    }
    return bookmarksRepository.save(p);
  }
}
