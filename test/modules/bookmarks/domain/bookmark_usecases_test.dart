import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/modules/bookmarks/domain/entities/bookmark.entity.dart';
import 'package:go_translator/src/modules/bookmarks/domain/repositories/bookmarks_repository.dart';
import 'package:go_translator/src/core/usecase/usecase.dart';
import 'package:go_translator/src/modules/bookmarks/domain/usecases/get_bookmarks.dart';
import 'package:go_translator/src/modules/bookmarks/domain/usecases/restore_bookmark.dart';
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

  test('SaveBookmark stamps the time and keeps both language codes', () async {
    final time = DateTime(2026, 11, 19, 10, 14);
    final saveBookmark = SaveBookmark(repository, now: () => time);

    await saveBookmark(
      const SaveBookmarkParams(
        sourceText: 'hello',
        targetText: 'bonjour',
        sourceLanguageCode: 'en',
        targetLanguageCode: 'fr',
      ),
    );

    final bookmark = repository.saved.single;
    expect(bookmark.savedAt, time);
    expect(bookmark.sourceLanguageCode, 'en');
    expect(bookmark.targetLanguageCode, 'fr');
  });

  test('SaveBookmark drops the target code when there is no translation', () async {
    final saveBookmark = SaveBookmark(repository);

    await saveBookmark(
      const SaveBookmarkParams(
        sourceText: 'hello',
        targetText: '  ',
        sourceLanguageCode: 'en',
        targetLanguageCode: 'fr',
      ),
    );

    expect(repository.saved.single.sourceLanguageCode, 'en');
    expect(repository.saved.single.targetLanguageCode, isNull);
  });

  test('RestoreBookmark puts the same bookmark back', () async {
    final original = BookmarkEntity(
      id: 'kept-id',
      sourceText: 'hello',
      savedAt: DateTime(2026, 11, 1),
    );

    await RestoreBookmark(repository)(original);

    expect(repository.saved.single.id, 'kept-id');
    expect(repository.saved.single.savedAt, DateTime(2026, 11, 1));
  });

  test('GetBookmarks lists newest first, undated ones last in stored order', () async {
    repository.saved.addAll([
      BookmarkEntity(id: 'old-undated-1', sourceText: 'a'),
      BookmarkEntity(id: 'older', sourceText: 'b', savedAt: DateTime(2026, 11, 1)),
      BookmarkEntity(id: 'old-undated-2', sourceText: 'c'),
      BookmarkEntity(id: 'newest', sourceText: 'd', savedAt: DateTime(2026, 11, 19)),
    ]);

    final ids = (await GetBookmarks(repository)(const NoParams())).map((b) => b.id);

    expect(ids, ['newest', 'older', 'old-undated-1', 'old-undated-2']);
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
