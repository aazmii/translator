import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/core/extensions/extensions.dart';

import '../../providers/translator.dart';
class HomeAppbar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final source = ref.watch(translatorProvider).sourceLanguage;
    final target = ref.watch(translatorProvider).targetLanguage;
    return AppBar(
      title: ListTile(
        onTap: ref.read(translatorProvider.notifier).swapLanguage,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: Center(child: Text(source.name.capitalize))),
            Icon(Icons.swap_horiz),
            Expanded(child: Center(child: Text(target.name.capitalize))),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}
