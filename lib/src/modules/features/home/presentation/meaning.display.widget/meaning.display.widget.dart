import 'package:flutter/material.dart';
import 'package:translator/src/core/extensions/extensions.dart';

import 'action.panel.dart';
import 'custom.textfield.dart';

class TranslationDisplayWidget extends StatelessWidget {
  const TranslationDisplayWidget({super.key, this.sourceText, this.targetText});
  final String? sourceText, targetText;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: SizedBox(
        height: context.height * 0.58,
        child: Column(
          children: [
            const SizedBox(width: 100, child: Divider(thickness: 2)),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: CustomTextField(text: sourceText)),
                    ActionPanel(text: targetText),
                  ],
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: CustomTextField(
                text: targetText,
                // text:  word.meanings?.isNotEmpty? word.meanings?.first.definitions?.first.definition ?? '',
                readOnly: true,
                // showLoader: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
