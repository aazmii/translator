import 'package:flutter/material.dart';
import 'package:translator/src/modules/home/presentation/home.view/components/action.panel.dart';
import 'package:translator/src/modules/home/presentation/home.view/components/custom.textfield.dart';

class TranslationCard extends StatelessWidget {
  const TranslationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: CustomTextField()),
          ActionPanel(),
        ],
      ),
    );
  }
}
