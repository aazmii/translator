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
  Future<({bool Function() isOpen, String? Function() result})> openPicker(WidgetTester tester) async {
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
                    builder: (_) => const OfflineLanguagesView(title: 'Translate To', selectionMode: true),
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

  testWidgets('the trailing icon still downloads Wi-Fi only, without asking', (tester) async {
    final picker = await openPicker(tester);

    await tester.tap(find.byIcon(Icons.download));
    await tester.pumpAndSettle();

    expect(find.text('Download Afrikaans?'), findsNothing);
    expect(languages.downloads.single, (code: 'af', wifiOnly: true));
    expect(picker.isOpen(), isTrue);
  });
}
