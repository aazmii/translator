import 'package:go_translator/src/core/di/providers.dart';
import 'package:go_translator/src/modules/bookmarks/data/datasource/bookmarks.local.datasource.impl.dart';
import 'package:go_translator/src/modules/bookmarks/data/repositories/bookmarks.repository.impl.dart';
import 'package:go_translator/src/modules/bookmarks/domain/entities/bookmark.entity.dart';
import 'package:go_translator/src/modules/bookmarks/domain/usecases/get.bookmarks.usecase.dart';
import 'package:go_translator/src/modules/bookmarks/domain/usecases/remove.bookmark.usecase.dart';
import 'package:go_translator/src/modules/bookmarks/domain/usecases/save.bookmark.usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bookmarks.controller.g.dart';

@riverpod
class BookmarksController extends _$BookmarksController {
  BookmarksRepositoryImpl _repository() {
    final box = ref.read(appBoxProvider);
    final local = BookmarksLocalDataSourceImpl(box);
    return BookmarksRepositoryImpl(local);
  }

  @override
  Future<List<BookmarkEntity>> build() async {
    final usecase = GetSavedTranslationUsecase(_repository());
    return usecase();
  }

  Future<void> refresh() async {
    final usecase = GetSavedTranslationUsecase(_repository());
    state = AsyncData(await usecase());
  }

  Future<void> saveBookmark({required String sourceText, String? targetText}) async {
    final source = sourceText.trim();
    if (source.isEmpty) {
      return;
    }

    final usecase = SaveBookmarkUsecase(_repository());
    final bookmark = BookmarkEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sourceText: source,
      targetText: targetText,
    );

    await usecase(p: bookmark);
    await refresh();
  }

  Future<void> removeBookmark(String id) async {
    final usecase = RemoveTranslationUsecase(_repository());
    await usecase(p: id);
    await refresh();
  }
}
