import 'package:go_translator/src/core/usecase/usecase.dart';

import '../entities/bookmark.entity.dart';
import '../repositories/bookmarks.reopsitory.dart';

class GetSavedTranslationUsecase implements AsyncUseCase {
  final BookmarksRepository savedBookmarks;

  GetSavedTranslationUsecase(this.savedBookmarks);

  @override
  Future<List<BookmarkEntity>> call({void p}) {
    return savedBookmarks.getBookmarks();
  }
}
