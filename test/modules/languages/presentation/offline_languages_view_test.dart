import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/modules/languages/presentation/view/offline.languages.view.dart';

import '../../../helpers/fake_offline_language_repository.dart';

const _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');

/// Fluttertoast starts a one-second timer per toast; tests that show one
/// wait it out so no timer is left pending.
const _toastTimer = Duration(seconds: 2);

void main() {
  late FakeOfflineLanguageRepository languages;
  late List<String> toasts;

  setUp(() {
    // English and French downloaded, Afrikaans not.
    languages = FakeOfflineLanguageRepository()..notDownloaded.add('af');
    toasts = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_toastChannel, (call) async {
      if (call.method == 'showToast') toasts.add((call.arguments as Map)['msg'] as String);
      return true;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_toastChannel, null);
  });

  /// Opens the picker from a host screen. `result` gives what the picker
  /// returned once it closed; `isOpen` is true while it's open.
  Future<({bool Function() isOpen, String? Function() result})> openPicker(
    WidgetTester tester, {
    String? targetLanguageCode,
  }) async {
    String? picked;
    var open = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [offlineLanguageRepositoryProvider.overrideWithValue(languages)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                open = true;
                picked = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OfflineLanguagesView(
                      title: 'Translate To',
                      selectionMode: true,
                      sourceLanguageCode: 'en',
                      targetLanguageCode: targetLanguageCode,
                    ),
                  ),
                );
                open = false;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return (isOpen: () => open, result: () => picked);
  }

  Future<void> confirmDownload(WidgetTester tester) async {
    await tester.tap(find.text('Afrikaans'));
    await tester.pumpAndSettle();
    expect(find.text('Download Afrikaans?'), findsOneWidget);
    await tester.tap(find.text('Download'));
    // The spinner never settles, so pump frames instead of settling.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('a downloaded language is returned straight away', (tester) async {
    final picker = await openPicker(tester);

    await tester.tap(find.text('French'));
    await tester.pumpAndSettle();

    expect(picker.isOpen(), isFalse);
    expect(picker.result(), 'fr');
    expect(languages.downloads, isEmpty);
  });

  testWidgets('cancelling the prompt stays put and downloads nothing', (tester) async {
    final picker = await openPicker(tester);

    await tester.tap(find.text('Afrikaans'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Download Afrikaans?'), findsNothing);
    expect(picker.isOpen(), isTrue);
    expect(languages.downloads, isEmpty);
  });

  testWidgets('a successful download returns the language, over any connection', (tester) async {
    languages.pendingDownload = Completer<bool>();
    final picker = await openPicker(tester);

    await confirmDownload(tester);
    expect(find.text('Downloading Afrikaans…'), findsOneWidget);
    expect(picker.isOpen(), isTrue);

    languages.pendingDownload!.complete(true);
    await tester.pumpAndSettle();

    expect(picker.isOpen(), isFalse);
    expect(picker.result(), 'af');
    expect(languages.downloads.single, (code: 'af', wifiOnly: false));
  });

  testWidgets('back does not close the loader', (tester) async {
    languages.pendingDownload = Completer<bool>();
    await openPicker(tester);
    await confirmDownload(tester);

    final popped = await tester.binding.handlePopRoute();
    await tester.pump();

    expect(popped, isTrue); // handled (blocked) by the app
    expect(find.text('Downloading Afrikaans…'), findsOneWidget);

    languages.pendingDownload!.complete(false);
    await tester.pumpAndSettle();
    await tester.pump(_toastTimer);
  });

  testWidgets('a failed download shows a message and stays on the list', (tester) async {
    languages.pendingDownload = Completer<bool>();
    final picker = await openPicker(tester);
    await confirmDownload(tester);

    languages.pendingDownload!.complete(false);
    await tester.pumpAndSettle();

    expect(find.text('Downloading Afrikaans…'), findsNothing);
    expect(picker.isOpen(), isTrue);
    expect(toasts, ["Couldn't download Afrikaans. Check your connection and try again."]);
    await tester.pump(_toastTimer);
  });

  testWidgets('cancel in the loader stays put, even when the download finishes later', (tester) async {
    languages.pendingDownload = Completer<bool>();
    final picker = await openPicker(tester);
    await confirmDownload(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Downloading Afrikaans…'), findsNothing);
    expect(picker.isOpen(), isTrue);

    languages.pendingDownload!.complete(true);
    await tester.pumpAndSettle();

    expect(picker.isOpen(), isTrue);
    expect(find.text('Translate To'), findsOneWidget);
    expect(toasts, isEmpty);
  });

  testWidgets('English has no delete button; other downloaded languages do', (tester) async {
    await openPicker(tester);

    Finder buttonIn(String name) =>
        find.descendant(of: find.widgetWithText(ListTile, name), matching: find.byType(IconButton));
    expect(buttonIn('English'), findsNothing);
    expect(find.descendant(of: find.widgetWithText(ListTile, 'French'), matching: find.byIcon(Icons.delete)), findsOneWidget);
  });

  group('delete', () {
    Finder trashIn(String name) =>
        find.descendant(of: find.widgetWithText(ListTile, name), matching: find.byIcon(Icons.delete));

    testWidgets('asks first; Cancel deletes nothing', (tester) async {
      await openPicker(tester);

      await tester.tap(trashIn('French'));
      await tester.pumpAndSettle();
      expect(find.text('Delete French?'), findsOneWidget);
      expect(find.text("You'll need to download it again to use it."), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(languages.deletes, isEmpty);
      expect(trashIn('French'), findsOneWidget);
    });

    testWidgets('Delete deletes, and the row offers a download again', (tester) async {
      final picker = await openPicker(tester);

      await tester.tap(trashIn('French'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(languages.deletes, ['fr']);
      expect(trashIn('French'), findsNothing);
      expect(
        find.descendant(of: find.widgetWithText(ListTile, 'French'), matching: find.byIcon(Icons.download)),
        findsOneWidget,
      );
      expect(picker.isOpen(), isTrue);
    });

    testWidgets('mentions it when the language is selected', (tester) async {
      await openPicker(tester, targetLanguageCode: 'fr');

      await tester.tap(trashIn('French'));
      await tester.pumpAndSettle();

      expect(
        find.text("French is your current target language. You'll need to download it again to use it."),
        findsOneWidget,
      );
    });

    testWidgets('a failed delete shows a message', (tester) async {
      languages.failDeletes = true;
      await openPicker(tester);

      await tester.tap(trashIn('French'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(toasts, ["Couldn't delete French. Please try again."]);
      expect(trashIn('French'), findsOneWidget);
      await tester.pump(_toastTimer);
    });
  });

  group('section headers', () {
    Future<void> search(WidgetTester tester, String text) async {
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), text);
      await tester.pumpAndSettle();
    }

    /// The text of each header, top to bottom, with the language under it.
    List<String> headersWithFirstLanguage(WidgetTester tester) {
      return tester.widgetList<Column>(find.byType(Column)).where((column) {
        return column.children.length == 2 && column.children.first is Text && column.children.last is ListTile;
      }).map((column) {
        final header = (column.children.first as Text).data!;
        final language = ((column.children.last as ListTile).title as Text).data!;
        return '$header: $language';
      }).toList();
    }

    testWidgets('full list: Downloaded above English, Other Languages above Afrikaans', (tester) async {
      await openPicker(tester);

      expect(headersWithFirstLanguage(tester), ['Downloaded: English', 'Other Languages: Afrikaans']);
      expect(find.text('Recent Languages'), findsNothing);
    });

    testWidgets('search with only missing languages shows only Other Languages', (tester) async {
      await openPicker(tester);
      await search(tester, 'afr');

      expect(headersWithFirstLanguage(tester), ['Other Languages: Afrikaans']);
    });

    testWidgets('search with only downloaded languages shows only Downloaded', (tester) async {
      await openPicker(tester);
      await search(tester, 'fre');

      expect(headersWithFirstLanguage(tester), ['Downloaded: French']);
    });

    testWidgets('search with no matches shows no headers', (tester) async {
      await openPicker(tester);
      await search(tester, 'zzz');

      expect(headersWithFirstLanguage(tester), isEmpty);
      expect(find.byType(ListTile), findsNothing);
    });
  });

  Future<void> tapDownloadIcon(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.download));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('the download icon shows the loader without asking, then stays on the list', (tester) async {
    languages.pendingDownload = Completer<bool>();
    final picker = await openPicker(tester);

    await tapDownloadIcon(tester);
    expect(find.text('Download Afrikaans?'), findsNothing);
    expect(find.text('Downloading Afrikaans…'), findsOneWidget);

    languages.pendingDownload!.complete(true);
    await tester.pumpAndSettle();

    expect(find.text('Downloading Afrikaans…'), findsNothing);
    expect(picker.isOpen(), isTrue);
    expect(picker.result(), isNull);
    expect(languages.downloads.single, (code: 'af', wifiOnly: false));
    expect(find.byIcon(Icons.download), findsNothing); // Afrikaans now shows delete
  });

  testWidgets('a failed download from the icon shows a message', (tester) async {
    languages.pendingDownload = Completer<bool>();
    final picker = await openPicker(tester);
    await tapDownloadIcon(tester);

    languages.pendingDownload!.complete(false);
    await tester.pumpAndSettle();

    expect(picker.isOpen(), isTrue);
    expect(toasts, ["Couldn't download Afrikaans. Check your connection and try again."]);
    await tester.pump(_toastTimer);
  });

  testWidgets('cancel in the icon loader stays on the list', (tester) async {
    languages.pendingDownload = Completer<bool>();
    final picker = await openPicker(tester);
    await tapDownloadIcon(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    languages.pendingDownload!.complete(true);
    await tester.pumpAndSettle();

    expect(picker.isOpen(), isTrue);
    expect(toasts, isEmpty);
  });
}
