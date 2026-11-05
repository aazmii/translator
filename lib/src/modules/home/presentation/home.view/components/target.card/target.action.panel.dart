import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart' show FlutterTts;
import 'package:go_translator/src/modules/home/presentation/home.view/helpers/tts.helper.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/translator.dart';

class TargetActionPanel extends ConsumerStatefulWidget {
  const TargetActionPanel({super.key, this.text});
  final String? text;
  @override
  ConsumerState<TargetActionPanel> createState() => _ActionPanelState();
}

class _ActionPanelState extends ConsumerState<TargetActionPanel> {
  final _flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    final translation = ref.watch(translatorProvider).value;
    final targetText = translation?.translatedText;
    final targetLanguageCode = translation?.targetLanguageCode ?? 'en';
    if (targetText == null || targetText.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisAlignment: .spaceBetween,
      mainAxisSize: .min,
      children: [
        IconButton(
          icon: Icon(Icons.copy),
          onPressed: () => Clipboard.setData(ClipboardData(text: targetText)),
        ),
        IconButton(
          onPressed: () async => _speak(text: targetText, languageCode: targetLanguageCode),
          icon: Icon(Icons.volume_up),
        ),
        IconButton(
          icon: Icon(Icons.share),
          onPressed: targetText.isNotEmpty ? () => SharePlus.instance.share(ShareParams(text: targetText)) : null,
        ),
      ],
    );
  }

  Future<void> _speak({required String text, required String languageCode}) async {
    await setTtsLanguage(_flutterTts, languageCode);
    await _flutterTts.speak(text);
  }
}
