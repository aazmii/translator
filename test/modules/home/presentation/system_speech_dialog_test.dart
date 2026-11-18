import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/speech.listening/system.speech.dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('go_translator/system_speech');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final calls = <MethodCall>[];
  void reply(Object? Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return handler(call);
    });
  }

  setUp(calls.clear);
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  SystemSpeechDialog android() => SystemSpeechDialog(channel: channel, isAndroid: true);

  test('sends the source language code and returns the text', () async {
    reply((_) => {'status': 'ok', 'text': 'আমি ভালো আছি'});
    final outcome = await android().recognize('bn');
    expect(outcome, isA<SystemSpeechText>().having((o) => o.text, 'text', 'আমি ভালো আছি'));
    expect(calls.single.method, 'recognize');
    expect(calls.single.arguments, {'language': 'bn'});
  });

  test('cancelled when the user closes the dialog', () async {
    reply((_) => {'status': 'cancelled'});
    expect(await android().recognize('en'), isA<SystemSpeechCancelled>());
  });

  test('unavailable when there is no Google app', () async {
    reply((_) => {'status': 'unavailable'});
    expect(await android().recognize('en'), isA<SystemSpeechUnavailable>());
  });

  test('unavailable when the channel has no handler', () async {
    expect(await android().recognize('en'), isA<SystemSpeechUnavailable>());
  });

  test('unavailable off Android, without calling the channel', () async {
    reply((_) => {'status': 'ok', 'text': 'x'});
    final outcome = await SystemSpeechDialog(channel: channel, isAndroid: false).recognize('en');
    expect(outcome, isA<SystemSpeechUnavailable>());
    expect(calls, isEmpty);
  });

  test('failed with the error code', () async {
    reply((_) => {'status': 'error', 'code': 'network'});
    final outcome = await android().recognize('en');
    expect(outcome, isA<SystemSpeechFailed>().having((o) => o.code, 'code', 'network'));
  });

  test('busy when a dialog is already open', () async {
    reply((_) => {'status': 'busy'});
    final outcome = await android().recognize('en');
    expect(outcome, isA<SystemSpeechFailed>().having((o) => o.code, 'code', 'busy'));
  });

  test('failed on a platform exception', () async {
    reply((_) => throw PlatformException(code: 'boom'));
    final outcome = await android().recognize('en');
    expect(outcome, isA<SystemSpeechFailed>().having((o) => o.code, 'code', 'boom'));
  });
}
