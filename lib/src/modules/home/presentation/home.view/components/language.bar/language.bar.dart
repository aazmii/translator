import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/config/router/provider/route.provider.dart';
import 'package:go_translator/src/modules/languages/domain/entities/language.dart';
import 'package:go_translator/src/modules/languages/presentation/providers/offline.languages.provider.dart';
import 'package:go_translator/src/modules/languages/presentation/view/offline.languages.view.dart';

import '../../helpers/language.name.dart';
import '../../helpers/translate.with.download.dart';
import '../../providers/translator.dart';

const _swapDuration = Duration(milliseconds: 300);
const _swapButtonSize = 44.0;
const _swapGap = 6.0;

/// Source and target language pills with a swap button between them. Tapping
/// a pill opens the language picker; swapping slides the names across and
/// spins the swap icon.
class LanguageBar extends ConsumerStatefulWidget {
  const LanguageBar({super.key});

  @override
  ConsumerState<LanguageBar> createState() => _LanguageBarState();
}

class _LanguageBarState extends ConsumerState<LanguageBar> with SingleTickerProviderStateMixin {
  // At rest the controller sits at 1 (labels in place). A swap restarts it
  // from 0, so each label starts on the other side and slides home.
  late final AnimationController _swapController = AnimationController(
    vsync: this,
    duration: _swapDuration,
    value: 1,
  );
  late final Animation<double> _swapProgress = CurvedAnimation(parent: _swapController, curve: Curves.easeInOut);
  double _iconTurns = 0;

  @override
  void dispose() {
    _swapController.dispose();
    super.dispose();
  }

  Future<void> _onSwap() async {
    FocusScope.of(context).unfocus();
    final animate = !MediaQuery.of(context).disableAnimations;
    final translator = ref.read(translatorProvider.notifier);
    // With a translation, the swap already leaves both texts correct, and
    // translating again would replace the original wording with a round trip.
    final translated = translator.value?.translatedText;
    final hadTranslation = translated != null && translated.isNotEmpty;
    final swap = translator.swapLanguage();
    if (animate) {
      setState(() => _iconTurns += 0.5);
      _swapController.forward(from: 0);
    }
    await swap;
    if (!hadTranslation && mounted) {
      await translateOrOfferDownload(context, ref);
    }
  }

  Future<void> _pick({required bool source, String? sourceCode, String? targetCode}) async {
    final code = await fadePush<String>(
      context,
      OfflineLanguagesView(
        title: source ? 'Translate From' : 'Translate To',
        selectionMode: true,
        sourceLanguageCode: sourceCode,
        targetLanguageCode: targetCode,
      ),
    );
    if (code == null) return;
    final translator = ref.read(translatorProvider.notifier);
    await (source ? translator.setSourceLanguage(code) : translator.setTargetLanguage(code));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final translation = ref.watch(translatorProvider).value;
    final sourceCode = translation?.sourceLanguageCode;
    final targetCode = translation?.targetLanguageCode;
    final languages = ref.watch(offlineLanguagesProvider).value ?? const <Language>[];
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: ShapeDecoration(shape: const StadiumBorder(), color: scheme.surfaceContainer),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Distance between the centres of the two pills.
          final distance = constraints.hasBoundedWidth
              ? (constraints.maxWidth + _swapButtonSize + 2 * _swapGap) / 2
              : 0.0;
          return Row(
            children: [
              Expanded(
                child: _SlidingLabel(
                  progress: _swapProgress,
                  // The new source label starts where the target was.
                  startOffset: distance,
                  child: _LanguagePill(
                    key: const Key('sourceLanguagePill'),
                    name: languageName(languages, sourceCode),
                    onTap: () => _pick(source: true, sourceCode: sourceCode, targetCode: targetCode),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _swapGap),
                child: AnimatedRotation(
                  turns: _iconTurns,
                  duration: reduceMotion ? Duration.zero : _swapDuration,
                  curve: Curves.easeInOut,
                  child: SizedBox.square(
                    dimension: _swapButtonSize,
                    child: IconButton.filled(
                      tooltip: 'Swap languages',
                      padding: EdgeInsets.zero,
                      onPressed: _onSwap,
                      icon: const Icon(Icons.swap_horiz, size: 20),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _SlidingLabel(
                  progress: _swapProgress,
                  // The new target label starts where the source was.
                  startOffset: -distance,
                  child: _LanguagePill(
                    key: const Key('targetLanguagePill'),
                    name: languageName(languages, targetCode),
                    onTap: () => _pick(source: false, sourceCode: sourceCode, targetCode: targetCode),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({super.key, required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      shape: const StadiumBorder(),
      elevation: theme.brightness == Brightness.light ? 1 : 0,
      shadowColor: scheme.shadow.withValues(alpha: 0.3),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurface),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_more, size: 16, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws [child] shifted by [startOffset] at progress 0, easing to no shift
/// at progress 1.
class _SlidingLabel extends StatelessWidget {
  const _SlidingLabel({required this.progress, required this.startOffset, required this.child});

  final Animation<double> progress;
  final double startOffset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      child: child,
      builder: (context, child) => Transform.translate(
        offset: Offset(startOffset * (1 - progress.value), 0),
        child: child,
      ),
    );
  }
}
