import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart' show FlutterTts;
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast, Toast, ToastGravity;
import 'package:go_translator/src/modules/bookmarks/presentation/providers/bookmarks.controller.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/helpers/translate.with.download.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/helpers/tts.helper.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/speech.listening/speech.listening.dialog.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/speech.listening/speech.recognizer.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/speech.listening/system.speech.dialog.dart';

import '../../providers/translator.dart';

void _toast(String message, {bool centre = true}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: centre ? ToastGravity.CENTER : null,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black87,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

/// Clears the source text and translation, keeping the keyboard up.
class SourceClearButton extends ConsumerWidget {
  const SourceClearButton({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Clear text',
      color: Theme.of(context).colorScheme.outline,
      onPressed: () {
        ref.read(translatorProvider.notifier).clear();
        controller.clear();
        FocusScope.of(context).requestFocus();
      },
      icon: const Icon(Icons.cancel_outlined, size: 20),
    );
  }
}

/// The source card's bottom row: speak, copy and bookmark on the left; mic
/// and Translate on the right. Speak, copy, bookmark and Translate are
/// disabled while there is no text.
class SourceActionPanel extends ConsumerStatefulWidget {
  const SourceActionPanel({super.key, required this.controller});
  final TextEditingController controller;
  @override
  ConsumerState<SourceActionPanel> createState() => _ActionPanelState();
}

class _ActionPanelState extends ConsumerState<SourceActionPanel> {
  final _flutterTts = FlutterTts();
  final _systemSpeech = SystemSpeechDialog();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final translation = ref.watch(translatorProvider).value;
    final sourceText = translation?.sourceText;
    final hasText = sourceText != null && sourceText.isNotEmpty;
    final sourceLanguageCode = translation?.sourceLanguageCode ?? 'en';

    // Sizes from the Stitch translator screen: 40px tool buttons 4px apart,
    // a 44px mic, 8px gap, and a 44px-high Translate pill.
    final toolStyle = IconButton.styleFrom(
      foregroundColor: scheme.onSurfaceVariant,
      fixedSize: const Size.square(40),
      minimumSize: const Size.square(40),
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    List<Widget> buttons(Widget gap) => [
      IconButton(
          tooltip: 'Listen',
          style: toolStyle,
          onPressed: hasText ? () => _speak(text: sourceText, languageCode: sourceLanguageCode) : null,
          icon: const Icon(Icons.volume_up_outlined, size: 22),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Copy',
          style: toolStyle,
          onPressed: hasText ? () => Clipboard.setData(ClipboardData(text: sourceText)) : null,
          icon: const Icon(Icons.content_copy_outlined, size: 20),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Bookmark',
          style: toolStyle,
          onPressed: hasText ? () => _bookmark(translation) : null,
          icon: const Icon(Icons.star_outline, size: 22),
        ),
        gap,
        IconButton(
          tooltip: 'Speak',
          style: IconButton.styleFrom(
            backgroundColor: scheme.surfaceContainer,
            foregroundColor: scheme.primary,
            fixedSize: const Size.square(44),
            minimumSize: const Size.square(44),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () => _dictate(sourceLanguageCode),
          icon: const Icon(Icons.mic_none, size: 22),
        ),
        const SizedBox(width: 8),
        _TranslateButton(onPressed: hasText ? _translate : null),
      ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || constraints.maxWidth >= _naturalWidth) {
          return Row(children: buttons(const Spacer()));
        }
        // Narrow phones (e.g. 320px wide): keep the design, scaled down to fit.
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(mainAxisSize: MainAxisSize.min, children: buttons(const SizedBox(width: 8))),
        );
      },
    );
  }

  /// The row's width with no space between the groups, measured with Inter
  /// on 2026-11-18 (3 x 40 + 2 x 4 + 44 + 8 + a 121.5px Translate button).
  static const _naturalWidth = 302.0;

  Future<void> _translate() async {
    ref.read(translatorProvider.notifier).setSourceText(widget.controller.text);
    await translateOrOfferDownload(context, ref);
    if (mounted) FocusScope.of(context).unfocus();
  }

  /// Saves the source text (and the translation, if any) as a bookmark.
  /// Works before translating (decision 2026-11-17).
  Future<void> _bookmark(TranslatorState? translation) async {
    final source = translation?.sourceText?.trim();
    if (source == null || source.isEmpty) return;
    try {
      final saved = await ref
          .read(bookmarksControllerProvider.notifier)
          .saveBookmark(sourceText: source, targetText: translation?.translatedText);
      _toast(saved ? 'Bookmarked' : 'Already bookmarked', centre: !saved);
    } catch (error) {
      debugPrint('Bookmark failed: $error');
      _toast('Failed to bookmark');
    }
  }

  Future<void> _dictate(String sourceLanguageCode) async {
    // Android: the system (Google) speech dialog, whose text goes straight
    // in. If it fails, or elsewhere / with no Google app, the in-app dialog,
    // which only returns text on Insert.
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
        if (!mounted) return;
        spoken = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (_) => SpeechListeningDialog(languageCode: sourceLanguageCode),
        );
    }
    if (spoken == null || spoken.trim().isEmpty || !mounted) return;
    final text = appendDictation(widget.controller.text, spoken);
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    ref.read(translatorProvider.notifier).setSourceText(text);
    await translateOrOfferDownload(context, ref);
  }

  Future<void> _speak({required String text, required String languageCode}) async {
    await setTtsLanguage(_flutterTts, languageCode);
    await _flutterTts.speak(text);
  }
}

/// The design's Translate pill: 44px high, 16px side padding, "Translate"
/// in label-lg, a 6px gap, an 18px down arrow, and a small shadow.
class _TranslateButton extends StatelessWidget {
  const _TranslateButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 44),
        fixedSize: const Size.fromHeight(44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: Theme.of(context).textTheme.labelLarge,
        elevation: 1,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Translate'),
          SizedBox(width: 6),
          Icon(Icons.arrow_downward, size: 18),
        ],
      ),
    );
  }
}
