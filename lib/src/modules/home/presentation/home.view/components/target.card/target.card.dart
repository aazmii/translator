import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/target.card/target.action.panel.dart';
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
    targetController.text = ref.watch(translatorProvider).value?.translatedText ?? '';
    return Card(
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Expanded(child: CustomTextField(controller: targetController, readOnly: true)),
          TargetActionPanel(),
        ],
      ),
    );
  }
}
