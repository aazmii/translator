import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../providers/translator.dart';

class TargetActionPanel extends StatefulWidget {
  const TargetActionPanel({super.key, this.text});
  final String? text;
  @override
  State<TargetActionPanel> createState() => _ActionPanelState();
}

class _ActionPanelState extends State<TargetActionPanel> {
  final _flutterTts = FlutterTts();
  Map<String, String>? voice;
  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () async {
            if (widget.text == null) return;
            // print(await _flutterTts.getLanguages);
            _flutterTts.speak(widget.text!);
          },
          icon: Icon(Icons.speaker),
        ),
        const IconButton(icon: Icon(Icons.copy), onPressed: null),
        const IconButton(icon: Icon(Icons.bookmark), onPressed: null),
        Consumer(builder: (context, ref, child) {
          return IconButton(
              onPressed: () async {
                await ref.read(translatorProvider.notifier).translate();
                if (context.mounted) FocusScope.of(context).unfocus();
              },
              icon: Icon(Icons.send));
        }),
      ],
    );
  }

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
