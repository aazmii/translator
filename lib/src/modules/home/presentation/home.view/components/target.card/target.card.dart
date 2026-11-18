import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/target.card/target.action.panel.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/custom.textfield.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/providers/translator.dart';
import 'package:go_translator/src/modules/languages/domain/entities/language.dart';
import 'package:go_translator/src/modules/languages/presentation/providers/offline.languages.provider.dart';

import '../../helpers/language.name.dart';
import '../card.surface.dart';

/// The translation card. Plain and laid out like the source card (same
/// surface, padding, 40px top row, text field and toolbar height); its top
/// row holds the target language's name (decision 2026-11-19: no glow,
/// badge or styled text).
class TargetCard extends ConsumerStatefulWidget {
  const TargetCard({super.key});

  @override
  ConsumerState<TargetCard> createState() => _TargetCardState();
}

class _TargetCardState extends ConsumerState<TargetCard> {
  late final TextEditingController targetController;
  @override
  initState() {
    super.initState();
    targetController = TextEditingController();
  }

  @override
  dispose() {
    targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translation = ref.watch(translatorProvider).value;
    targetController.text = translation?.translatedText ?? '';
    final languages = ref.watch(offlineLanguagesProvider).value ?? const <Language>[];
    final name = languageName(languages, translation?.targetLanguageCode);

    return CardSurface(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Column(
        children: [
          // Same height as the source card's Clear row, so the cards line up.
          SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface),
                ),
              ),
            ),
          ),
          Expanded(
            child: CustomTextField(
              controller: targetController,
              readOnly: true,
              hintText: 'Translation appears here',
              contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            ),
          ),
          const TargetActionPanel(),
        ],
      ),
    );
  }
}
