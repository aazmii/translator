import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// What the voice input dialog needs from a speech recognizer. Wrapping the
/// plugin lets the dialog be tested with a fake.
abstract interface class SpeechRecognizer {
  /// False when speech isn't available (no permission, no recognizer).
  Future<bool> initialize({
    required void Function(String errorCode) onError,
    required void Function(String status) onStatus,
  });

  /// Locale ids the device can recognize, e.g. "fr-FR" or "fr_FR".
  Future<List<String>> localeIds();

  /// The device's own speech locale, if known.
  Future<String?> systemLocaleId();

  Future<void> listen({
    required String localeId,
    required void Function(String words, bool isFinal) onResult,
  });

  Future<void> stop();
  Future<void> cancel();
}

final class PluginSpeechRecognizer implements SpeechRecognizer {
  final SpeechToText _speech = SpeechToText();

  @override
  Future<bool> initialize({
    required void Function(String errorCode) onError,
    required void Function(String status) onStatus,
  }) {
    return _speech.initialize(
      onError: (SpeechRecognitionError error) => onError(error.errorMsg),
      onStatus: onStatus,
    );
  }

  @override
  Future<List<String>> localeIds() async =>
      (await _speech.locales()).map((locale) => locale.localeId).toList();

  @override
  Future<String?> systemLocaleId() async => (await _speech.systemLocale())?.localeId;

  @override
  Future<void> listen({
    required String localeId,
    required void Function(String words, bool isFinal) onResult,
  }) {
    return _speech.listen(
      onResult: (SpeechRecognitionResult result) => onResult(result.recognizedWords, result.finalResult),
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        onDevice: false,
        cancelOnError: true,
        partialResults: true,
        autoPunctuation: true,
        enableHapticFeedback: true,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 8),
        localeId: localeId,
      ),
    );
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  Future<void> cancel() => _speech.cancel();
}

/// Picks the device speech locale for a language [code] such as "fr".
/// Prefers the device's own locale when it's the same language, otherwise
/// the first match. Null when the device has no locale for the language.
String? matchSpeechLocale(String code, List<String> localeIds, String? systemLocaleId) {
  String language(String localeId) => localeId.split(RegExp('[-_]')).first.toLowerCase();
  final wanted = code.toLowerCase();
  if (systemLocaleId != null && language(systemLocaleId) == wanted && localeIds.contains(systemLocaleId)) {
    return systemLocaleId;
  }
  for (final localeId in localeIds) {
    if (language(localeId) == wanted) return localeId;
  }
  return null;
}

/// A readable sentence for a speech plugin error code. The raw code is logged
/// by the caller.
String speechErrorMessage(String errorCode) {
  switch (errorCode) {
    case 'error_no_match':
    case 'error_speech_timeout':
      return "Didn't catch that. Tap the mic to try again.";
    case 'error_network':
    case 'error_network_timeout':
    case 'error_server':
    case 'error_server_disconnected':
      return 'Voice input needs an internet connection.';
    case 'error_permission':
      return 'Microphone access is off. Allow it in Settings.';
    case 'error_language_not_supported':
    case 'error_language_unavailable':
      return "Voice input isn't available for this language on this device.";
    case 'error_busy':
    case 'error_too_many_requests':
      return 'Voice input is busy. Wait a moment and tap the mic.';
    default:
      return 'Voice input stopped. Tap the mic to try again.';
  }
}

/// Adds dictated [spoken] text after [existing] text, separated by a space.
String appendDictation(String existing, String spoken) {
  final added = spoken.trim();
  if (added.isEmpty) return existing;
  final base = existing.trimRight();
  return base.isEmpty ? added : '$base $added';
}
