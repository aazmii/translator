import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart' show FlutterTts;
import 'package:go_translator/src/modules/home/presentation/home.view/helpers/tts.helper.dart';

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

  @override
  Widget build(BuildContext context) {
    final translation = ref.watch(translatorProvider).value;
    final sourceText = translation?.sourceText;
    final sourceLanguageCode = translation?.sourceLanguageCode ?? 'en';

    return Column(
      mainAxisAlignment: .spaceBetween,
      mainAxisSize: .min,
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
          IconButton(
            icon: Icon(Icons.paste),
            onPressed: () => Clipboard.setData(ClipboardData(text: sourceText)),
          ),
          IconButton(
            onPressed: () async => _speak(text: sourceText, languageCode: sourceLanguageCode),
            icon: Icon(Icons.volume_up),
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
          IconButton(onPressed: () {}, icon: Icon(Icons.mic)),
        ],
      ],
    );
  }

  /// it should open speech to text instead
  Future<void> _speak({required String text, required String languageCode}) async {
    await setTtsLanguage(_flutterTts, languageCode);
    await _flutterTts.speak(text);
  }
}
