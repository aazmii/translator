import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/config/router/provider/route.provider.dart';
import 'package:go_translator/src/core/extensions/extensions.dart';
import 'package:go_translator/src/modules/languages/domain/entities/language.dart';
import 'package:go_translator/src/modules/languages/presentation/providers/offline.languages.provider.dart';
import 'package:go_translator/src/modules/languages/presentation/view/offline.languages.view.dart';

import '../../providers/translator.dart';

class HomeAppbar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final sourceCode = ref.watch(translatorProvider).value?.sourceLanguageCode;
    final targetCode = ref.watch(translatorProvider).value?.targetLanguageCode;
    final languages =
        ref.watch(offlineLanguagesProvider).value ?? const <Language>[];
    return AppBar(
      title: ListTile(
        title: Row(
          mainAxisAlignment: .spaceAround,
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final code = await fadePush<String>(
                    context,
                    const OfflineLanguagesView(
                      title: 'Translate From',
                      selectionMode: true,
                    ),
                  );
                  if (code != null) {
                    await ref
                        .read(translatorProvider.notifier)
                        .setSourceLanguage(code);
                  }
                },
                child: Center(
                  child: Text(_languageName(languages, sourceCode).capitalize),
                ),
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
                onTap: () async {
                  final code = await fadePush<String>(
                    context,
                    const OfflineLanguagesView(
                      title: 'Translate To',
                      selectionMode: true,
                    ),
                  );
                  if (code != null) {
                    await ref
                        .read(translatorProvider.notifier)
                        .setTargetLanguage(code);
                  }
                },
                child: Center(
                  child: Text(_languageName(languages, targetCode).capitalize),
                ),
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

String _languageName(List<Language> languages, String? code) {
  if (code == null || code.isEmpty) return '';
  final language = languages.cast<Language?>().firstWhere(
    (language) => language?.code == code,
    orElse: () => null,
  );
  return language?.name ?? code;
}
