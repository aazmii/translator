import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/target.card/target.action.panel.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/custom.textfield.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/providers/translator.dart';
import 'package:go_translator/src/modules/languages/domain/entities/language.dart';
import 'package:go_translator/src/modules/languages/presentation/providers/offline.languages.provider.dart';

import '../../helpers/language.name.dart';
import '../card.surface.dart';

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
    final scheme = theme.colorScheme;
    final translation = ref.watch(translatorProvider).value;
    targetController.text = translation?.translatedText ?? '';
    final languages = ref.watch(offlineLanguagesProvider).value ?? const <Language>[];
    final name = languageName(languages, translation?.targetLanguageCode);

    return CardSurface(
      color: scheme.surfaceContainerLow,
      child: Column(
        children: [
          // Header: target language and an on-device badge (every translation
          // runs on the phone).
          SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      name.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: ShapeDecoration(shape: const StadiumBorder(), color: scheme.secondaryContainer),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.offline_pin, size: 12, color: scheme.onSecondaryContainer),
                        const SizedBox(width: 2),
                        Text(
                          'On-device',
                          style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSecondaryContainer),
                        ),
                      ],
                    ),
                  ),
                ],
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
