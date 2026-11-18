import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// What happened in the system (Google) speech dialog.
sealed class SystemSpeechOutcome {
  const SystemSpeechOutcome();
}

/// The user spoke; [text] is the top result.
final class SystemSpeechText extends SystemSpeechOutcome {
  const SystemSpeechText(this.text);
  final String text;
}

/// The user closed the dialog without a result.
final class SystemSpeechCancelled extends SystemSpeechOutcome {
  const SystemSpeechCancelled();
}

/// No system speech dialog here (not Android, or no Google app). Use the
/// in-app dialog instead.
final class SystemSpeechUnavailable extends SystemSpeechOutcome {
  const SystemSpeechUnavailable();
}

/// The dialog ran but failed, or one is already open. [code] is for logs.
final class SystemSpeechFailed extends SystemSpeechOutcome {
  const SystemSpeechFailed(this.code);
  final String code;
}

/// Opens Android's system speech dialog (the Google app's "Try saying
/// something" screen) through MainActivity.
class SystemSpeechDialog {
  SystemSpeechDialog({MethodChannel? channel, bool? isAndroid})
    : _channel = channel ?? const MethodChannel('go_translator/system_speech'),
      _isAndroid = isAndroid ?? (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  final MethodChannel _channel;
  final bool _isAndroid;

  /// Listens in [languageCode], e.g. "bn". The dialog closes on its own
  /// after a pause.
  Future<SystemSpeechOutcome> recognize(String languageCode) async {
    if (!_isAndroid) return const SystemSpeechUnavailable();
    try {
      final reply = await _channel.invokeMapMethod<String, Object?>('recognize', {'language': languageCode});
      final outcome = switch (reply?['status']) {
        'ok' => SystemSpeechText(reply?['text'] as String? ?? ''),
        'cancelled' => const SystemSpeechCancelled(),
        'unavailable' => const SystemSpeechUnavailable(),
        'busy' => const SystemSpeechFailed('busy'),
        _ => SystemSpeechFailed(reply?['code'] as String? ?? 'unknown'),
      };
      debugPrint('System speech: ${outcome is SystemSpeechFailed ? 'failed (${outcome.code})' : outcome.runtimeType}');
      return outcome;
    } on MissingPluginException {
      // No handler, e.g. an older build of MainActivity.
      debugPrint('System speech: no channel handler, using the in-app dialog');
      return const SystemSpeechUnavailable();
    } on PlatformException catch (error) {
      debugPrint('System speech failed: ${error.code} ${error.message}');
      return SystemSpeechFailed(error.code);
    }
  }
}
