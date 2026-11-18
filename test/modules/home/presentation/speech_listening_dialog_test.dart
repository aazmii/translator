import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/speech.listening/speech.listening.dialog.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/speech.listening/speech.recognizer.dart';

void main() {
  late _FakeRecognizer recognizer;

  setUp(() => recognizer = _FakeRecognizer());

  /// Opens the dialog the way the source panel does. `result()` is what it
  /// returned; `closed()` is true once it has closed.
  Future<({String? Function() result, bool Function() closed})> openDialog(
    WidgetTester tester, {
    String languageCode = 'fr',
  }) async {
    String? returned;
    var closed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              returned = await showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (_) => SpeechListeningDialog(languageCode: languageCode, recognizer: recognizer),
              );
              closed = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await settle(tester);
    return (result: () => returned, closed: () => closed);
  }

  testWidgets('starts listening in the matched device locale', (tester) async {
    await openDialog(tester);

    expect(recognizer.listenedLocales, ['fr-FR']);
    expect(find.text('Listening…'), findsOneWidget);
  });

  testWidgets('partial results show only in the dialog; Cancel returns nothing', (tester) async {
    final dialog = await openDialog(tester);

    recognizer.emit('bonjour tout', isFinal: false);
    await tester.pump();
    expect(find.textContaining('bonjour tout'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await settle(tester);

    expect(dialog.closed(), isTrue);
    expect(dialog.result(), isNull);
    expect(recognizer.cancels, greaterThan(0));
  });

  testWidgets('Insert returns the draft, including the phrase in progress', (tester) async {
    final dialog = await openDialog(tester);

    recognizer.emit('bonjour', isFinal: true);
    await tapMic(tester); // second phrase
    recognizer.emit('le monde', isFinal: false);
    await tester.pump();

    await tester.tap(find.text('Insert'));
    await settle(tester);

    expect(dialog.result(), 'bonjour le monde');
  });

  testWidgets('Insert is disabled while nothing has been said', (tester) async {
    await openDialog(tester);

    final insert = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Insert'));
    expect(insert.onPressed, isNull);
  });

  testWidgets('Try again while listening discards the phrase in progress and waits for the mic', (tester) async {
    final dialog = await openDialog(tester);
    recognizer.emit('bonjour', isFinal: true);
    await tapMic(tester);
    recognizer.emit('le mond', isFinal: false);
    await tester.pump();

    await tester.tap(find.byTooltip('Try again'));
    await settle(tester);
    expect(recognizer.listenedLocales.length, 2); // not restarted
    expect(find.byTooltip('Speak'), findsOneWidget);
    expect(find.textContaining('le mond'), findsNothing);
    expect(find.textContaining('bonjour'), findsOneWidget);

    await tapMic(tester);
    recognizer.emit('le monde', isFinal: true);
    await tester.pump();
    await tester.tap(find.text('Insert'));
    await settle(tester);

    expect(dialog.result(), 'bonjour le monde');
  });

  testWidgets('Try again when stopped drops the last phrase and waits for the mic', (tester) async {
    final dialog = await openDialog(tester);
    recognizer.emit('bonjour', isFinal: true);
    await tapMic(tester);
    recognizer.emit('le mond', isFinal: true);
    await tester.pump();

    await tester.tap(find.byTooltip('Try again'));
    await settle(tester);
    expect(recognizer.listenedLocales.length, 2); // not restarted
    expect(find.textContaining('le mond'), findsNothing);

    await tapMic(tester);
    recognizer.emit('le monde', isFinal: true);
    await tester.pump();
    await tester.tap(find.text('Insert'));
    await settle(tester);

    expect(dialog.result(), 'bonjour le monde');
  });

  testWidgets('a late result from a cancelled phrase is ignored', (tester) async {
    final dialog = await openDialog(tester);
    final stale = recognizer.latestOnResult!;

    await tester.tap(find.byTooltip('Try again'));
    await settle(tester);
    stale('wrong words', true);
    await tapMic(tester);
    recognizer.emit('bonjour', isFinal: true);
    await tester.pump();
    await tester.tap(find.text('Insert'));
    await settle(tester);

    expect(dialog.result(), 'bonjour');
  });

  testWidgets('stopping keeps the phrase when no final result arrives', (tester) async {
    final dialog = await openDialog(tester);
    recognizer.emit('bonjour', isFinal: false);
    await tester.pump();

    await tester.tap(find.byTooltip('Stop'));
    await settle(tester);
    expect(recognizer.stops, 1);
    expect(find.byTooltip('Speak'), findsOneWidget);

    await tester.tap(find.text('Insert'));
    await settle(tester);
    expect(dialog.result(), 'bonjour');
  });

  testWidgets('stopping, then the final result: the phrase appears once, as the final words', (tester) async {
    final dialog = await openDialog(tester);
    recognizer.emit('bonjour le', isFinal: false);
    await tester.pump();

    await tester.tap(find.byTooltip('Stop'));
    await settle(tester);
    recognizer.emit('bonjour le monde', isFinal: true); // arrives after stop
    recognizer.emit('bonjour le monde', isFinal: true); // and a duplicate
    await tester.pump();

    await tester.tap(find.text('Insert'));
    await settle(tester);
    expect(dialog.result(), 'bonjour le monde');
  });

  testWidgets('a late final result after Try again does not replace the earlier phrase', (tester) async {
    final dialog = await openDialog(tester);
    recognizer.emit('bonjour', isFinal: true);
    await tapMic(tester);
    final second = recognizer.latestOnResult!;
    second('le mond', false);
    await tester.pump();
    await tester.tap(find.byTooltip('Stop'));
    await settle(tester);

    await tester.tap(find.byTooltip('Try again')); // drops "le mond"
    await settle(tester);
    second('le monde', true); // late final for the dropped phrase
    await tester.pump();

    await tester.tap(find.text('Insert'));
    await settle(tester);
    expect(dialog.result(), 'bonjour');
  });

  testWidgets('errors are shown as a readable sentence', (tester) async {
    await openDialog(tester);

    recognizer.onError!('error_no_match');
    await tester.pump();

    expect(find.text("Didn't catch that. Tap the mic to try again."), findsOneWidget);
    expect(find.textContaining('error_'), findsNothing);
  });

  testWidgets('unavailable recognizer: reason shown, no mic', (tester) async {
    recognizer.available = false;
    await openDialog(tester);

    expect(find.textContaining("Voice input isn't available"), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(recognizer.listenedLocales, isEmpty);
  });

  testWidgets('unsupported language: reason shown, no mic', (tester) async {
    await openDialog(tester, languageCode: 'af');

    expect(find.text("Voice input isn't available for this language on this device."), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}

/// The glow animation never settles while listening, so pump a few frames.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapMic(WidgetTester tester) async {
  await tester.pump(); // show the mic again after a final result
  await tester.tap(find.byTooltip('Speak'));
  await settle(tester);
}

final class _FakeRecognizer implements SpeechRecognizer {
  bool available = true;
  final List<String> listenedLocales = [];
  void Function(String words, bool isFinal)? latestOnResult;
  void Function(String errorCode)? onError;
  void Function(String status)? onStatus;
  int stops = 0;
  int cancels = 0;

  void emit(String words, {required bool isFinal}) => latestOnResult!(words, isFinal);

  @override
  Future<bool> initialize({
    required void Function(String errorCode) onError,
    required void Function(String status) onStatus,
  }) async {
    this.onError = onError;
    this.onStatus = onStatus;
    return available;
  }

  @override
  Future<List<String>> localeIds() async => ['en-US', 'fr-FR'];

  @override
  Future<String?> systemLocaleId() async => 'en-US';

  @override
  Future<void> listen({
    required String localeId,
    required void Function(String words, bool isFinal) onResult,
  }) async {
    listenedLocales.add(localeId);
    latestOnResult = onResult;
  }

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> cancel() async => cancels++;
}
