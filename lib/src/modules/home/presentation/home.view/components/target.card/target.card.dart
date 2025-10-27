import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/target.card/action.panel.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/custom.textfield.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/providers/translator.dart';

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
    // print(ref.watch(onDeviceTranslatorPProvider).translatedText);
    targetController.text = ref.watch(translatorProvider).translatedText ?? '';
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomTextField(
              controller: targetController,
              readOnly: true,
            ),
          ),
          TargetActionPanel(),
        ],
      ),
    );
  }
}
