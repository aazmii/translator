import 'package:flutter_tts/flutter_tts.dart' show FlutterTts;

/// Sets the language for the given FlutterTts instance.
///
/// It first normalizes the given language code, then extracts the primary code
/// from the normalized code. It then queries the list of available voices
/// for the first voice that matches the normalized code, starts with the
/// primary code, or has a locale that is equal to the normalized code.
///
/// If a matching voice is found, it sets the voice for the given FlutterTts
/// instance and returns. If no matching voice is found, it sets the language to
/// 'en-US' and returns.
Future<void> setTtsLanguage(FlutterTts flutterTts, String languageCode) async {
  final normalizedCode = languageCode.toLowerCase();
  final primaryCode = normalizedCode.split('-').first;
  final voices = await flutterTts.getVoices;

  if (voices is List) {
    final matchedVoice = voices.cast<dynamic>().map((v) => v as Map).cast<Map>().firstWhere(
          (voice) {
            final locale = (voice['locale']?.toString() ?? '').toLowerCase().replaceAll('_', '-');
            return locale == normalizedCode || locale.startsWith('$normalizedCode-') || locale.startsWith('$primaryCode-');
          },
          orElse: () => const {},
        );

    final name = matchedVoice['name']?.toString();
    final locale = matchedVoice['locale']?.toString();

    if (name != null && locale != null) {
      await flutterTts.setVoice({'name': name, 'locale': locale});
      return;
    }
  }

  try {
    await flutterTts.setLanguage(languageCode);
  } catch (_) {
    await flutterTts.setLanguage('en-US');
  }
}
