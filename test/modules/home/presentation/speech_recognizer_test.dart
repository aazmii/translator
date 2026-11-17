import 'package:flutter_test/flutter_test.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/speech.listening/speech.recognizer.dart';

void main() {
  group('matchSpeechLocale', () {
    const locales = ['en-US', 'en-GB', 'fr-FR', 'fr_CA', 'de-DE'];

    test('prefers the device locale when it is the same language', () {
      expect(matchSpeechLocale('en', locales, 'en-GB'), 'en-GB');
    });

    test('falls back to the first locale of the language', () {
      expect(matchSpeechLocale('fr', locales, 'en-GB'), 'fr-FR');
    });

    test('accepts underscores and ignores case', () {
      expect(matchSpeechLocale('FR', ['fr_CA'], null), 'fr_CA');
    });

    test('null when the device has no locale for the language', () {
      expect(matchSpeechLocale('af', locales, 'en-US'), isNull);
    });

    test('ignores a device locale the recognizer does not list', () {
      expect(matchSpeechLocale('en', ['en-US'], 'en-IN'), 'en-US');
    });
  });

  group('speechErrorMessage', () {
    test('maps known codes to readable sentences', () {
      expect(speechErrorMessage('error_no_match'), "Didn't catch that. Tap the mic to try again.");
      expect(speechErrorMessage('error_network'), 'Voice input needs an internet connection.');
      expect(speechErrorMessage('error_permission'), 'Microphone access is off. Allow it in Settings.');
    });

    test('never shows a raw code', () {
      expect(speechErrorMessage('error_something_new'), isNot(contains('error_')));
    });
  });

  group('appendDictation', () {
    test('adds after existing text with one space', () {
      expect(appendDictation('hello', ' world '), 'hello world');
      expect(appendDictation('hello  ', 'world'), 'hello world');
    });

    test('uses the spoken text alone when the box is empty or blank', () {
      expect(appendDictation('', 'world'), 'world');
      expect(appendDictation('   ', 'world'), 'world');
    });

    test('leaves the text alone when nothing was said', () {
      expect(appendDictation('hello', '  '), 'hello');
    });
  });
}
