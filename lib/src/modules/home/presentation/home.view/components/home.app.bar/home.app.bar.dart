import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/config/router/provider/route.provider.dart';
import 'package:go_translator/src/core/extensions/extensions.dart';
import 'package:go_translator/src/modules/languages/domain/entities/language.dart';
import 'package:go_translator/src/modules/languages/presentation/providers/offline.languages.provider.dart';
import 'package:go_translator/src/modules/languages/presentation/view/offline.languages.view.dart';

import '../../helpers/translation.toast.dart';
import '../../providers/translator.dart';

const _swapDuration = Duration(milliseconds: 300);
const _swapButtonWidth = 48.0;

class HomeAppbar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const HomeAppbar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  ConsumerState<HomeAppbar> createState() => _HomeAppbarState();
}

class _HomeAppbarState extends ConsumerState<HomeAppbar>
    with SingleTickerProviderStateMixin {
  // At rest the controller sits at 1 (labels in place). A swap restarts it
  // from 0, so each label starts on the other side and slides home.
  late final AnimationController _swapController = AnimationController(
    vsync: this,
    duration: _swapDuration,
    value: 1,
  );
  late final Animation<double> _swapProgress = CurvedAnimation(
    parent: _swapController,
    curve: Curves.easeInOut,
  );
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
    if (!hadTranslation) {
      showTranslateOutcomeToast(await translator.translate());
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceCode = ref.watch(translatorProvider).value?.sourceLanguageCode;
    final targetCode = ref.watch(translatorProvider).value?.targetLanguageCode;
    final languages =
        ref.watch(offlineLanguagesProvider).value ?? const <Language>[];
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return AppBar(
      title: ListTile(
        title: LayoutBuilder(
          builder: (context, constraints) {
            // Distance between the centres of the two labels.
            final distance = constraints.hasBoundedWidth
                ? (constraints.maxWidth + _swapButtonWidth) / 2
                : 0.0;
            return Row(
              mainAxisAlignment: .spaceAround,
              children: [
                Expanded(
                  child: _SlidingLabel(
                    progress: _swapProgress,
                    // The new source label starts where the target was.
                    startOffset: distance,
                    child: InkWell(
                      onTap: () async {
                        final code = await fadePush<String>(
                          context,
                          const OfflineLanguagesView(
                            title: 'Translate From',
                            selectionMode: true,
                          ),
                        );
                        if (code != null) {
                          await ref
                              .read(translatorProvider.notifier)
                              .setSourceLanguage(code);
                        }
                      },
                      child: Center(
                        child: Text(
                          _languageName(languages, sourceCode).capitalize,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: _swapButtonWidth,
                  child: AnimatedRotation(
                    turns: _iconTurns,
                    duration: reduceMotion ? Duration.zero : _swapDuration,
                    curve: Curves.easeInOut,
                    child: IconButton(
                      onPressed: _onSwap,
                      icon: const Icon(Icons.swap_horiz),
                    ),
                  ),
                ),
                Expanded(
                  child: _SlidingLabel(
                    progress: _swapProgress,
                    // The new target label starts where the source was.
                    startOffset: -distance,
                    child: InkWell(
                      onTap: () async {
                        final code = await fadePush<String>(
                          context,
                          const OfflineLanguagesView(
                            title: 'Translate To',
                            selectionMode: true,
                          ),
                        );
                        if (code != null) {
                          await ref
                              .read(translatorProvider.notifier)
                              .setTargetLanguage(code);
                        }
                      },
                      child: Center(
                        child: Text(
                          _languageName(languages, targetCode).capitalize,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Draws [child] shifted by [startOffset] at progress 0, easing to no shift
/// at progress 1.
class _SlidingLabel extends StatelessWidget {
  const _SlidingLabel({
    required this.progress,
    required this.startOffset,
    required this.child,
  });

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

String _languageName(List<Language> languages, String? code) {
  if (code == null || code.isEmpty) return '';
  final language = languages.cast<Language?>().firstWhere(
    (language) => language?.code == code,
    orElse: () => null,
  );
  return language?.name ?? code;
}
