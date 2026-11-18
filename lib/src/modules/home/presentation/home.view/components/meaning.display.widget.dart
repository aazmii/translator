import 'package:flutter/material.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/components/source.card/source.action.panel.dart';

import 'target.card/target.action.panel.dart';
import 'custom.textfield.dart';

class TranslationDisplayWidget extends StatelessWidget {
  const TranslationDisplayWidget({super.key, this.sourceText, this.targetText});
  final String? sourceText, targetText;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Card(
            child: Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(child: CustomTextField()),
                // Unused widget; the panels never read the old `text` argument.
                SourceActionPanel(controller: TextEditingController(text: sourceText)),
              ],
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: Card(
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    // initialValue: targetText,
                    // text:  word.meanings?.isNotEmpty? word.meanings?.first.definitions?.first.definition ?? '',
                    readOnly: true,
                    // showLoader: true,
                  ),
                ),
                TargetActionPanel(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
