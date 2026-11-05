import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/core/usecase/usecase.dart';
import 'package:go_translator/src/modules/bookmarks/domain/entities/bookmark.entity.dart';
import 'package:go_translator/src/modules/bookmarks/domain/usecases/save_bookmark.dart';

final bookmarksControllerProvider =
    AsyncNotifierProvider<BookmarksController, List<BookmarkEntity>>(
      BookmarksController.new,
    );

final class BookmarksController extends AsyncNotifier<List<BookmarkEntity>> {
  @override
  Future<List<BookmarkEntity>> build() =>
      ref.watch(getBookmarksProvider)(const NoParams());

  Future<void> refresh() async {
    state = AsyncData(await ref.read(getBookmarksProvider)(const NoParams()));
  }

  Future<bool> saveBookmark({
    required String sourceText,
    String? targetText,
  }) async {
    final saved = await ref.read(saveBookmarkProvider)(
      SaveBookmarkParams(sourceText: sourceText, targetText: targetText),
    );
    if (saved) await refresh();
    return saved;
  }

  Future<void> removeBookmark(String id) async {
    await ref.read(removeBookmarkProvider)(id);
    await refresh();
  }
}
