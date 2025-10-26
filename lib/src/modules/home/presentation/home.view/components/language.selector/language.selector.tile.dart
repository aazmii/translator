import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/ondevice.translator.provider.dart';

class HomeAppbar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final source = ref.watch(sourceLanguageProvider);
    final target = ref.watch(targetLanguageProvider);

    return AppBar(
      title: ListTile(
        onTap: ref.read(onDeviceTranslatorPProvider.notifier).swapLanguage,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(source.name),
            Icon(Icons.swap_horiz),
            Text(target.name),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}
