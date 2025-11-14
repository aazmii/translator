import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../providers/translator.dart';

class TargetActionPanel extends ConsumerStatefulWidget {
  const TargetActionPanel({super.key, this.text});
  final String? text;
  @override
  ConsumerState<TargetActionPanel> createState() => _ActionPanelState();
}

class _ActionPanelState extends ConsumerState<TargetActionPanel> {
  final _flutterTts = FlutterTts();
  Map<String, String>? voice;
  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  @override
  Widget build(BuildContext context) {
    final targetText = ref.watch(translatorProvider).value?.translatedText;
    if (targetText == null || targetText.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisAlignment: .spaceBetween,
      mainAxisSize: .min,
      children: [
        IconButton(icon: Icon(Icons.copy), onPressed: () => Clipboard.setData(ClipboardData(text: targetText))),
        IconButton(
          onPressed: () async => await _flutterTts.speak(targetText),
          icon: Icon(Icons.speaker),
        ),
        const IconButton(icon: Icon(Icons.bookmark), onPressed: null),
        const IconButton(icon: Icon(Icons.share), onPressed: null),
      ],
    );
  }

  // TODO: init with proper language
  void _initTTS() async {
    var voices = await _flutterTts.getVoices;

    var defaultVoiceRaw = await _flutterTts.getDefaultVoice;

    Map<String, String> defaultVoice = Map<String, String>.from(defaultVoiceRaw);

    if (voices.any((v) => v['name'] == defaultVoice['name'])) {
      await _flutterTts.setVoice({
        'name': defaultVoice['name']!,
        'locale': defaultVoice['locale']!,
      });
    } else {
      await _flutterTts.setLanguage('en-US');
    }

    setState(() {
      voice = defaultVoice;
    });
  }
}
