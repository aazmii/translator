import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/translator.dart';
import '../custom.textfield.dart';
import 'source.action.panel.dart';

class SourceCard extends ConsumerStatefulWidget {
  const SourceCard({super.key});

  @override
  ConsumerState<SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends ConsumerState<SourceCard> {
  late final TextEditingController sourceController;
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    sourceController = TextEditingController()
      ..addListener(() {
        ref.read(translatorProvider.notifier).setSourceText(sourceController.text);
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(_focusNode);
      });
    });
  }

  @override
  dispose() {
    sourceController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The text field owns its text, so push state changes made elsewhere
    // (such as a language swap) back into it.
    ref.listen(translatorProvider.select((s) => s.value?.sourceText), (_, next) {
      final text = next ?? '';
      if (text == sourceController.text) return;
      sourceController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
    return Card(
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Expanded(
            child: CustomTextField(
              focusNode: _focusNode,
              controller: sourceController,
              autofocus: true,
              hintText: 'Text..',
              // onChanged: ref.read(translatorProvider.notifier).setSourceText,
            ),
          ),
          SourceActionPanel(controller: sourceController),
        ],
      ),
    );
  }
}
