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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sourceController = TextEditingController();
  }

  @override
  dispose() {
    sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: CustomTextField(
            controller: sourceController,
            onChanged: ref.read(translatorProvider.notifier).setSourceText,
          )),
          SourceActionPanel(controller: sourceController),
        ],
      ),
    );
  }
}
