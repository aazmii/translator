import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/config/router/provider/route.provider.dart';
import 'package:go_translator/src/core/extensions/extensions.dart';
import 'package:go_translator/src/modules/languages/presentation/view/offline.languages.view.dart';

import '../../providers/translator.dart';

class HomeAppbar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final source = ref.watch(translatorProvider).value?.sourceLanguage;
    final target = ref.watch(translatorProvider).value?.targetLanguage;
    return AppBar(
      title: ListTile(
        title: Row(
          mainAxisAlignment: .spaceAround,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  fadePush(context, OfflineLanguagesView(title: 'Translate From'));
                },
                child: Center(child: Text(source?.name.capitalize ?? '')),
              ),
            ),
            IconButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                ref.read(translatorProvider.notifier).swapLanguage();
                await ref.read(translatorProvider.notifier).translate();
              },
              icon: const Icon(Icons.swap_horiz),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  fadePush(context, OfflineLanguagesView(title: 'Translate To'));
                },
                child: Center(child: Text(target?.name.capitalize ?? '')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60);
}
