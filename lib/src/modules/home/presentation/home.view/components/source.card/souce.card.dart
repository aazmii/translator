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
    sourceController = TextEditingController();

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
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: CustomTextField(
            focusNode: _focusNode,
            controller: sourceController,
            autofocus: true,
            onChanged: ref.read(translatorProvider.notifier).setSourceText,
          )),
          SourceActionPanel(controller: sourceController),
        ],
      ),
    );
  }
}
