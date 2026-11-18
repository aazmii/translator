import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart' show FlutterTts;
import 'package:go_translator/src/modules/home/presentation/home.view/helpers/tts.helper.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/translator.dart';

/// The translation card's bottom row: speak (tinted), copy and share.
/// Disabled while there is no translation.
class TargetActionPanel extends ConsumerStatefulWidget {
  const TargetActionPanel({super.key});
  @override
  ConsumerState<TargetActionPanel> createState() => _ActionPanelState();
}

class _ActionPanelState extends ConsumerState<TargetActionPanel> {
  final _flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final translation = ref.watch(translatorProvider).value;
    final targetText = translation?.translatedText;
    final hasText = targetText != null && targetText.isNotEmpty;
    final targetLanguageCode = translation?.targetLanguageCode ?? 'en';
    return Row(
      children: [
        IconButton(
          tooltip: 'Listen',
          style: IconButton.styleFrom(
            backgroundColor: scheme.secondaryContainer.withValues(alpha: 0.6),
            foregroundColor: scheme.primary,
          ),
          onPressed: hasText ? () => _speak(text: targetText, languageCode: targetLanguageCode) : null,
          icon: const Icon(Icons.volume_up_outlined),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Copy',
          color: scheme.onSurfaceVariant,
          onPressed: hasText ? () => Clipboard.setData(ClipboardData(text: targetText)) : null,
          icon: const Icon(Icons.content_copy_outlined, size: 20),
        ),
        IconButton(
          tooltip: 'Share',
          color: scheme.onSurfaceVariant,
          onPressed: hasText ? () => SharePlus.instance.share(ShareParams(text: targetText)) : null,
          icon: const Icon(Icons.share_outlined, size: 20),
        ),
      ],
    );
  }

  Future<void> _speak({required String text, required String languageCode}) async {
    await setTtsLanguage(_flutterTts, languageCode);
    await _flutterTts.speak(text);
  }
}
