import 'package:flutter/material.dart';

import 'meaning.display.widget/meaning.display.widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translator')),
      body: TranslationDisplayWidget()
    );
  }
}
