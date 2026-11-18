import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart' show FlutterTts;
import 'package:go_translator/src/modules/home/presentation/home.view/helpers/bookmark.current.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/helpers/tts.helper.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/translator.dart';

/// The translation card's bottom row, styled like the source card's: Listen,
/// Copy and Share (plain 40px, 4px apart) on the left, and the Save pill on
/// the right. All are disabled while there is no translation.
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

    // Same as the source card's tool buttons.
    ButtonStyle tool() => IconButton.styleFrom(
      foregroundColor: scheme.onSurfaceVariant,
      fixedSize: const Size.square(40),
      minimumSize: const Size.square(40),
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    // 44px high like the source card's row (its mic is 44px), so both cards'
    // text areas are the same height.
    return SizedBox(
      height: 44,
      child: Row(
      children: [
        IconButton(
          tooltip: 'Listen',
          style: tool(),
          onPressed: hasText ? () => _speak(text: targetText, languageCode: targetLanguageCode) : null,
          icon: const Icon(Icons.volume_up_outlined, size: 22),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Copy',
          style: tool(),
          onPressed: hasText ? () => Clipboard.setData(ClipboardData(text: targetText)) : null,
          icon: const Icon(Icons.content_copy_outlined, size: 20),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Share',
          style: tool(),
          onPressed: hasText ? () => SharePlus.instance.share(ShareParams(text: targetText)) : null,
          icon: const Icon(Icons.share_outlined, size: 20),
        ),
        const Spacer(),
        _SaveButton(onPressed: hasText ? () => bookmarkCurrentTranslation(ref) : null),
      ],
      ),
    );
  }

  Future<void> _speak({required String text, required String languageCode}) async {
    await setTtsLanguage(_flutterTts, languageCode);
    await _flutterTts.speak(text);
  }
}

/// The design's Save pill: 36px high, 12px side padding, surface-container-
/// high, a 16px teal "bookmark add" icon, a 4px gap, and "Save" in label-md.
class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: scheme.surfaceContainerHigh,
        foregroundColor: scheme.onSurface,
        disabledBackgroundColor: scheme.surfaceContainerHigh.withValues(alpha: 0.5),
        disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
        minimumSize: const Size(0, 36),
        fixedSize: const Size.fromHeight(36),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: theme.textTheme.labelMedium,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_add_outlined,
            size: 16,
            color: onPressed == null ? scheme.onSurface.withValues(alpha: 0.38) : scheme.primary,
          ),
          const SizedBox(width: 4),
          const Text('Save'),
        ],
      ),
    );
  }
}
