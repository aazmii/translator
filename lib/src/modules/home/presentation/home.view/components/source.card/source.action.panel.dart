import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart' show FlutterTts;

import '../../providers/translator.dart';

class SourceActionPanel extends ConsumerStatefulWidget {
  const SourceActionPanel({super.key, this.text, this.controller});
  final TextEditingController? controller;
  final String? text;
  @override
  ConsumerState<SourceActionPanel> createState() => _ActionPanelState();
}

class _ActionPanelState extends ConsumerState<SourceActionPanel> {
  final _flutterTts = FlutterTts();
  Map<String, String>? voice;
  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  @override
  Widget build(BuildContext context) {
    final sourceText = ref.watch(translatorProvider).sourceText;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (sourceText != null && sourceText.isNotEmpty) ...[
          IconButton(
            onPressed: () {
              ref.read(translatorProvider.notifier).clear();
              widget.controller?.clear();
              FocusScope.of(context).requestFocus();
            },
            icon: Icon(Icons.close),
          ),
          IconButton(icon: Icon(Icons.copy), onPressed: () => Clipboard.setData(ClipboardData(text: sourceText))),
          IconButton(
            onPressed: () async => await _flutterTts.speak(sourceText),
            icon: Icon(Icons.speaker),
          ),
          IconButton(icon: Icon(Icons.bookmark), onPressed: null),
          Spacer(),
          IconButton(
            onPressed: () async {
              ref.read(translatorProvider.notifier).setSourceText(widget.controller?.text ?? '');
              await ref.read(translatorProvider.notifier).translate();
              if (context.mounted) FocusScope.of(context).unfocus();
            },
            icon: Icon(Icons.send),
          ),
        ] else ...[
          IconButton(
            onPressed: () async {
              widget.controller?.clear();
              if (context.mounted) FocusScope.of(context).unfocus();

              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data != null && data.text != null) {
                ref.read(translatorProvider.notifier).setSourceText(data.text!);
                widget.controller?.text = data.text!;
                await ref.read(translatorProvider.notifier).translate();
              }
            },
            icon: Icon(Icons.paste),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.mic),
          ),
        ]
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
