import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/core/extensions/extensions.dart';
import 'package:go_translator/src/modules/languages/presentation/providers/offline.languages.provider.dart';

class OfflineLanguagesView extends ConsumerWidget {
  const OfflineLanguagesView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Languages')),
      body: ref.watch(offlineLanguagesProvider).when(
            data: (languages) {
              return ListView.separated(
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                itemBuilder: (context, i) {
                  return ListTile(
                    title: Text(languages[i].name.capitalize),
                    trailing: IconButton(
                      icon: Icon(languages[i].isDownloaded ? Icons.delete : Icons.download),
                      onPressed: () {
                        if (languages[i].isDownloaded) {
                          ref.read(offlineLanguagesProvider.notifier).deleteLanguage(languages[i].code);
                        } else {
                          ref.read(offlineLanguagesProvider.notifier).downloadLanguage(languages[i].code);
                        }
                      },
                    ),
                  );
                },
                separatorBuilder: (context, i) => Divider(),
                itemCount: languages.length,
              );
            },
            error: (e, s) => Text('error'),
            loading: () => Center(
              child: CircularProgressIndicator(),
            ),
          ),
    );
  }
}
