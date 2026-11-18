import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/modules/languages/presentation/components/language.card.dart';
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
    bool selectionMode = true,
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
                      title: selectionMode ? 'Translate To' : 'Offline Languages',
                      selectionMode: selectionMode,
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

  Finder rowOf(String name) => find.widgetWithText(LanguageCard, name);

  testWidgets('English has no delete button but a System chip; other downloaded languages have delete', (tester) async {
    await openPicker(tester);

    expect(find.descendant(of: rowOf('English'), matching: find.byType(IconButton)), findsNothing);
    expect(find.descendant(of: rowOf('English'), matching: find.text('System')), findsOneWidget);
    expect(find.descendant(of: rowOf('French'), matching: find.byIcon(Icons.delete_outline)), findsOneWidget);
  });

  group('delete', () {
    Finder trashIn(String name) => find.descendant(of: rowOf(name), matching: find.byIcon(Icons.delete_outline));
    const frenchWarning = "You won't be able to translate French offline until you download it again.";

    testWidgets('asks first; Cancel deletes nothing', (tester) async {
      await openPicker(tester);

      await tester.tap(trashIn('French'));
      await tester.pumpAndSettle();
      expect(find.text('Delete French?'), findsOneWidget);
      expect(find.text(frenchWarning), findsOneWidget);

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
      expect(find.descendant(of: rowOf('French'), matching: find.byIcon(Icons.download)), findsOneWidget);
      expect(find.text('French removed'), findsOneWidget);
      expect(picker.isOpen(), isTrue);
    });

    testWidgets('mentions it when the language is selected', (tester) async {
      await openPicker(tester, targetLanguageCode: 'fr');

      await tester.tap(trashIn('French'));
      await tester.pumpAndSettle();

      expect(find.text('French is your current target language. $frenchWarning'), findsOneWidget);
    });

    testWidgets('a failed delete shows a message', (tester) async {
      languages.failDeletes = true;
      await openPicker(tester);

      await tester.tap(trashIn('French'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't delete French. Please try again."), findsOneWidget);
      expect(toasts, isEmpty);
      expect(trashIn('French'), findsOneWidget);
    });
  });

  group('sections and search', () {
    const downloadedHeader = 'Downloaded Languages';
    // Renamed from "Available for Download" in 597d83a ("update text").
    const availableHeader = 'Available';

    Future<void> search(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pumpAndSettle();
    }

    /// Section headers and language names, top to bottom.
    List<String> listed(WidgetTester tester) {
      final names = {'English', 'French', 'Afrikaans', downloadedHeader, availableHeader};
      final texts = find.byWidgetPredicate((widget) => widget is Text && names.contains(widget.data));
      final found = texts.evaluate().toList()
        ..sort((a, b) => tester.getTopLeft(find.byWidget(a.widget)).dy.compareTo(tester.getTopLeft(find.byWidget(b.widget)).dy));
      return found.map((element) => (element.widget as Text).data!).toList();
    }

    testWidgets('full list: downloaded languages, then available ones', (tester) async {
      await openPicker(tester);

      expect(listed(tester), [downloadedHeader, 'English', 'French', availableHeader, 'Afrikaans']);
    });

    testWidgets('search with only missing languages shows only the Available section', (tester) async {
      await openPicker(tester);
      await search(tester, 'afr');

      expect(listed(tester), [availableHeader, 'Afrikaans']);
    });

    testWidgets('search with only downloaded languages shows only Downloaded Languages', (tester) async {
      await openPicker(tester);
      await search(tester, 'fre');

      expect(listed(tester), [downloadedHeader, 'French']);
    });

    testWidgets('search matches the native name', (tester) async {
      await openPicker(tester);
      await search(tester, 'Fran');

      expect(listed(tester), [downloadedHeader, 'French']);
    });

    testWidgets('search with no matches shows No languages found', (tester) async {
      await openPicker(tester);
      await search(tester, 'zzz');

      expect(listed(tester), isEmpty);
      expect(find.byType(LanguageCard), findsNothing);
      expect(find.text('No languages found'), findsOneWidget);
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
    expect(find.text('Afrikaans downloaded'), findsOneWidget);
  });

  testWidgets('Offline Languages screen: tapping a missing row downloads it without asking', (tester) async {
    languages.pendingDownload = Completer<bool>();
    final screen = await openPicker(tester, selectionMode: false);

    await tester.tap(find.text('Afrikaans'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Download Afrikaans?'), findsNothing);
    expect(find.text('Downloading Afrikaans…'), findsOneWidget);

    languages.pendingDownload!.complete(true);
    await tester.pumpAndSettle();

    expect(screen.isOpen(), isTrue);
    expect(screen.result(), isNull);
    expect(languages.downloads.single, (code: 'af', wifiOnly: false));
    expect(find.text('Afrikaans downloaded'), findsOneWidget);
  });

  testWidgets('Offline Languages screen: tapping a downloaded row does nothing', (tester) async {
    final screen = await openPicker(tester, selectionMode: false);

    await tester.tap(find.text('French'));
    await tester.pumpAndSettle();

    expect(screen.isOpen(), isTrue);
    expect(languages.downloads, isEmpty);
    expect(languages.deletes, isEmpty);
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
