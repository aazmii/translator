import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/action.panel.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/custom.textfield.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/providers/translator.dart';
 
class SourceCard extends ConsumerWidget {
  const SourceCard({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: CustomTextField(
            onChanged: ref.read(translatorProvider.notifier).setSourceText,
          )),
          ActionPanel(),
        ],
      ),
    );
  }
}

class TargetCard extends ConsumerWidget {
  const TargetCard({super.key});

  @override
  Widget build(BuildContext context, ref) {
    // print(ref.watch(onDeviceTranslatorPProvider).translatedText);
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: CustomTextField(
            initialValue: ref.watch(translatorProvider).translatedText,
          )),
          ActionPanel(),
        ],
      ),
    );
  }
}
