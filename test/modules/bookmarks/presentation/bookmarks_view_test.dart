import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/modules/bookmarks/domain/entities/bookmark.entity.dart';
import 'package:go_translator/src/modules/bookmarks/domain/repositories/bookmarks_repository.dart';
import 'package:go_translator/src/modules/bookmarks/presentation/view/bookmarks.view.dart';
import 'package:go_translator/src/theme/themes/dark/dark.theme.dart';
import 'package:go_translator/src/theme/themes/light/light.theme.dart';

const _ttsChannel = MethodChannel('flutter_tts');

void main() {
  late _FakeBookmarksRepository repository;

  setUpAll(() async {
    // Real Inter widths, so the 320px overflow checks match the phone.
    final loader = FontLoader('Inter');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/fonts/Inter-$weight.ttf'));
    }
    await loader.load();
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _ttsChannel,
      (_) async => 1,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_ttsChannel, null);
  });

  final now = DateTime.now();
  BookmarkEntity full() => BookmarkEntity(
    id: 'full',
    sourceText: 'Where is the train station?',
    targetText: 'Où est la gare ?',
    savedAt: DateTime(now.year, now.month, now.day, 10, 14),
    sourceLanguageCode: 'en',
    targetLanguageCode: 'fr',
  );
  BookmarkEntity textOnly() => BookmarkEntity(
    id: 'text-only',
    sourceText: 'Thank you',
    savedAt: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)),
    sourceLanguageCode: 'en',
  );
  // Saved before dates and languages were stored.
  BookmarkEntity old() => BookmarkEntity(id: 'old', sourceText: 'Good night', targetText: 'Bonne nuit');

  Future<void> pumpBookmarks(
    WidgetTester tester,
    List<BookmarkEntity> bookmarks, {
    ThemeData? theme,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repository = _FakeBookmarksRepository(bookmarks);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bookmarksRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(theme: theme ?? lightTheme, home: const BookmarksView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a full card: date, both texts with codes, Listen, Copy, Share, Delete', (tester) async {
    await pumpBookmarks(tester, [full()]);

    expect(find.text('Bookmarks'), findsOneWidget);
    expect(find.text('SAVED'), findsOneWidget);
    expect(find.text('Newest first'), findsOneWidget);
    expect(find.textContaining('Today, 10:14'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('FR'), findsOneWidget);
    expect(find.text('Where is the train station?'), findsOneWidget);
    expect(find.text('Où est la gare ?'), findsOneWidget);
    expect(find.byTooltip('Listen'), findsOneWidget);
    expect(find.byTooltip('Copy'), findsOneWidget);
    expect(find.byTooltip('Share'), findsOneWidget);
    expect(find.byTooltip('Delete'), findsOneWidget);
  });

  testWidgets('without a translation: no Listen, no target code; "Yesterday"', (tester) async {
    await pumpBookmarks(tester, [textOnly()]);

    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.byTooltip('Listen'), findsNothing);
    expect(find.byTooltip('Copy'), findsOneWidget);
  });

  testWidgets('an old bookmark: no date, no codes, no Listen, no "Newest first"', (tester) async {
    await pumpBookmarks(tester, [old()]);

    expect(find.text('Good night'), findsOneWidget);
    expect(find.text('Bonne nuit'), findsOneWidget);
    expect(find.text('Newest first'), findsNothing);
    expect(find.byTooltip('Listen'), findsNothing);
    expect(find.textContaining('Today'), findsNothing);
  });

  testWidgets('Copy copies the translation', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String?;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await pumpBookmarks(tester, [full()]);

    await tester.tap(find.byTooltip('Copy'));
    await tester.pump();

    expect(copied, 'Où est la gare ?');
  });

  testWidgets('search matches source or translation, ignoring case', (tester) async {
    await pumpBookmarks(tester, [full(), textOnly(), old()]);

    await tester.enterText(find.byType(TextField), 'GARE');
    await tester.pumpAndSettle();
    expect(find.text('Where is the train station?'), findsOneWidget);
    expect(find.text('Thank you'), findsNothing);
    expect(find.text('Good night'), findsNothing);

    await tester.enterText(find.byType(TextField), 'thank');
    await tester.pumpAndSettle();
    expect(find.text('Thank you'), findsOneWidget);
    expect(find.text('Where is the train station?'), findsNothing);
  });

  testWidgets('a search with no results says so; Clear search brings them back', (tester) async {
    await pumpBookmarks(tester, [full()]);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No bookmarks match'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Where is the train station?'), findsOneWidget);
  });

  testWidgets('the Delete button deletes; Undo puts it back unchanged', (tester) async {
    await pumpBookmarks(tester, [full(), textOnly()]);

    await tester.tap(find.byTooltip('Delete').first);
    await tester.pumpAndSettle();
    expect(find.text('Where is the train station?'), findsNothing);
    expect(repository.items.map((b) => b.id), ['text-only']);
    expect(find.text('Bookmark deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Where is the train station?'), findsOneWidget);
    final restored = repository.items.singleWhere((b) => b.id == 'full');
    expect(restored.savedAt, full().savedAt);
    expect(restored.targetLanguageCode, 'fr');
  });

  testWidgets('swiping left deletes, with Undo', (tester) async {
    await pumpBookmarks(tester, [full()]);

    await tester.drag(find.text('Où est la gare ?'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(repository.items, isEmpty);
    expect(find.text('Bookmark deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Où est la gare ?'), findsOneWidget);
  });

  testWidgets('the Undo SnackBar goes away on its own', (tester) async {
    await pumpBookmarks(tester, [full()]);
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Bookmark deleted'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Bookmark deleted'), findsNothing);
  });

  testWidgets('no bookmarks: the empty state, no search field', (tester) async {
    await pumpBookmarks(tester, []);

    expect(find.text('No bookmarks yet'), findsOneWidget);
    expect(find.text('Tap the star on the translator page to save a phrase here.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('deleting the last bookmark shows the empty state', (tester) async {
    await pumpBookmarks(tester, [full()]);
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No bookmarks yet'), findsOneWidget);
  });

  testWidgets('nothing shows what the app does not have', (tester) async {
    await pumpBookmarks(tester, [full()]);
    for (final text in ['Recently Pinned', 'Quick Tip', 'Empty State Preview', 'Sorted by Date']) {
      expect(find.textContaining(text), findsNothing, reason: text);
    }
    expect(find.byIcon(Icons.star), findsNothing);
  });

  // Decision 2026-11-19: Bookmarks has a back arrow, not the drawer.
  testWidgets('Bookmarks has a back arrow and no drawer; Back returns to the first page', (tester) async {
    repository = _FakeBookmarksRepository([full()]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bookmarksRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BookmarksView())),
                child: const Text('first page'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('first page'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Open navigation menu'), findsNothing);
    expect(find.byType(Drawer), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(BookmarksView), findsNothing);
    expect(find.text('first page'), findsOneWidget);
  });

  for (final (name, theme) in [('light', lightTheme), ('dark', darkTheme)]) {
    testWidgets('no overflow on a 320px phone in $name mode, long texts and the empty state', (tester) async {
      final long = BookmarkEntity(
        id: 'long',
        sourceText: 'a long sentence ' * 12,
        targetText: 'une longue phrase ' * 12,
        savedAt: DateTime(2026, 1, 2),
        sourceLanguageCode: 'en',
        targetLanguageCode: 'fr',
      );
      await pumpBookmarks(tester, [long, full(), textOnly(), old()], theme: theme, size: const Size(320, 568));
      expect(tester.takeException(), isNull);

      await pumpBookmarks(tester, [], theme: theme, size: const Size(320, 568));
      expect(tester.takeException(), isNull);
    });
  }
}

final class _FakeBookmarksRepository implements BookmarksRepository {
  _FakeBookmarksRepository(List<BookmarkEntity> initial) : items = [...initial];

  final List<BookmarkEntity> items;

  @override
  Future<List<BookmarkEntity>> getBookmarks() async => [...items];

  @override
  Future<bool> containsSourceText(String sourceText) async => items.any((b) => b.sourceText == sourceText);

  @override
  Future<void> save(BookmarkEntity bookmark) async => items.add(bookmark);

  @override
  Future<void> remove(String id) async => items.removeWhere((b) => b.id == id);
}
