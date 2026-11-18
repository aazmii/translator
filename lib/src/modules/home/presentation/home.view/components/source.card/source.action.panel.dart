import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart' show FlutterTts;
import 'package:fluttertoast/fluttertoast.dart'
    show Fluttertoast, Toast, ToastGravity;
import 'package:go_translator/src/modules/bookmarks/presentation/providers/bookmarks.controller.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/helpers/translate.with.download.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/helpers/tts.helper.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/speech.listening/speech.listening.dialog.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/speech.listening/speech.recognizer.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/speech.listening/system.speech.dialog.dart';

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
  final _systemSpeech = SystemSpeechDialog();

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
            icon: Icon(Icons.copy),
            onPressed: () => Clipboard.setData(ClipboardData(text: sourceText)),
          ),
          IconButton(
            onPressed: () async =>
                _speak(text: sourceText, languageCode: sourceLanguageCode),
            icon: Icon(Icons.volume_up),
          ),
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () async {
              final source = translation?.sourceText?.trim();
              if (source == null || source.isEmpty) return;

              try {
                final saved = await ref
                    .read(bookmarksControllerProvider.notifier)
                    .saveBookmark(
                      sourceText: source,
                      targetText: translation?.translatedText,
                    );
                if (!saved) {
                  Fluttertoast.showToast(
                    msg: 'Already bookmarked',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  return;
                }

                Fluttertoast.showToast(
                  msg: 'Bookmarked',
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              } catch (_) {
                Fluttertoast.showToast(
                  msg: 'Failed to bookmark',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            },
          ),
          Spacer(),
          IconButton(
            onPressed: () async {
              ref
                  .read(translatorProvider.notifier)
                  .setSourceText(widget.controller?.text ?? '');
              await translateOrOfferDownload(context, ref);
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
                if (context.mounted) await translateOrOfferDownload(context, ref);
              }
            },
            icon: Icon(Icons.paste),
          ),
          IconButton(
            onPressed: () async {
              // Android: the system (Google) speech dialog, whose text goes
              // straight in. If it fails, or elsewhere / with no Google app,
              // the in-app dialog, which only returns text on Insert.
              final String? spoken;
              switch (await _systemSpeech.recognize(sourceLanguageCode)) {
                case SystemSpeechText(:final text):
                  spoken = text;
                case SystemSpeechCancelled():
                  return;
                case SystemSpeechFailed(code: 'busy'):
                  // A system dialog is already open; don't compete for the mic.
                  debugPrint('Voice input: system dialog already open');
                  return;
                case SystemSpeechFailed() || SystemSpeechUnavailable():
                  if (!context.mounted) return;
                  spoken = await showDialog<String>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => SpeechListeningDialog(languageCode: sourceLanguageCode),
                  );
              }
              if (spoken == null || spoken.trim().isEmpty || !context.mounted) return;
              final text = appendDictation(widget.controller?.text ?? '', spoken);
              widget.controller?.value = TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
              ref.read(translatorProvider.notifier).setSourceText(text);
              await translateOrOfferDownload(context, ref);
            },
            icon: Icon(Icons.mic),
          ),
        ],
      ],
    );
  }

  /// it should open speech to text instead
  Future<void> _speak({
    required String text,
    required String languageCode,
  }) async {
    await setTtsLanguage(_flutterTts, languageCode);
    await _flutterTts.speak(text);
  }
}
