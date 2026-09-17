import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/modules/bookmarks/domain/entities/bookmark.entity.dart';
import 'package:go_translator/src/modules/bookmarks/domain/repositories/bookmarks_repository.dart';
import 'package:go_translator/src/modules/bookmarks/domain/usecases/save_bookmark.dart';

void main() {
  late _FakeBookmarksRepository repository;

  setUp(() => repository = _FakeBookmarksRepository());

  test('SaveBookmark validates, normalizes, and creates the entity', () async {
    final saveBookmark = SaveBookmark(
      repository,
      createId: () => 'bookmark-id',
    );

    final saved = await saveBookmark(
      const SaveBookmarkParams(
        sourceText: '  hello  ',
        targetText: '  bonjour  ',
      ),
    );

    expect(saved, isTrue);
    expect(repository.saved.single.id, 'bookmark-id');
    expect(repository.saved.single.sourceText, 'hello');
    expect(repository.saved.single.targetText, 'bonjour');
  });

  test('SaveBookmark rejects blank source text', () {
    final saveBookmark = SaveBookmark(repository);

    expect(
      () => saveBookmark(const SaveBookmarkParams(sourceText: '  ')),
      throwsArgumentError,
    );
  });

  test('SaveBookmark prevents duplicate source text', () async {
    repository.containsResult = true;
    final saveBookmark = SaveBookmark(repository);

    final saved = await saveBookmark(
      const SaveBookmarkParams(sourceText: '  hello  '),
    );

    expect(saved, isFalse);
    expect(repository.saved, isEmpty);
    expect(repository.lastLookup, 'hello');
  });
}

final class _FakeBookmarksRepository implements BookmarksRepository {
  final saved = <BookmarkEntity>[];
  bool containsResult = false;
  String? lastLookup;

  @override
  Future<bool> containsSourceText(String sourceText) async {
    lastLookup = sourceText;
    return containsResult;
  }

  @override
  Future<List<BookmarkEntity>> getBookmarks() async => saved;

  @override
  Future<void> remove(String id) async {
    saved.removeWhere((bookmark) => bookmark.id == id);
  }

  @override
  Future<void> save(BookmarkEntity bookmark) async => saved.add(bookmark);
}
