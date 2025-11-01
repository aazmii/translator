import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/core/extensions/extensions.dart';
import 'package:go_translator/src/modules/languages/presentation/providers/offline.languages.provider.dart';

class OfflineLanguagesView extends ConsumerWidget {
  const OfflineLanguagesView({super.key, required this.title, this.onPickLanguage});
  final String title;
  final VoidCallback? onPickLanguage;
  @override
  Widget build(BuildContext context, ref) {
    final languages = ref.watch(offlineLanguagesProvider).value;
    final downloaded = languages?.where((l) => l.isDownloaded).toList();
    if (languages == null) return Center(child: CircularProgressIndicator());

    /// Make a new list keeping downoaded languages first
    final sortedList = [...languages.where((l) => l.isDownloaded), ...languages.where((l) => !l.isDownloaded)];

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 22.0),
              child: Text(title, style: context.theme.textTheme.headlineSmall),
            ),
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                itemBuilder: (context, i) {
                  final language = sortedList[i];
                  if (i == 0) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recent Languages', style: TextStyle(color: context.theme.colorScheme.primary)),
                        ListTile(
                          onTap: () => onPickLanguage?.call(),
                          title: Text(language.name.capitalize),
                          trailing: IconButton(
                            icon: Icon(language.isDownloaded ? Icons.delete : Icons.download),
                            onPressed: () {
                              if (language.isDownloaded) {
                                ref.read(offlineLanguagesProvider.notifier).deleteLanguage(language.code);
                              } else {
                                ref.read(offlineLanguagesProvider.notifier).downloadLanguage(language.code);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  if (i == downloaded!.length) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Other Languages', style: TextStyle(color: context.theme.colorScheme.primary)),
                        ListTile(
                          onTap: () => onPickLanguage?.call(),
                          title: Text(language.name.capitalize),
                          trailing: IconButton(
                            icon: Icon(language.isDownloaded ? Icons.delete : Icons.download),
                            onPressed: () {
                              if (language.isDownloaded) {
                                ref.read(offlineLanguagesProvider.notifier).deleteLanguage(language.code);
                              } else {
                                ref.read(offlineLanguagesProvider.notifier).downloadLanguage(language.code);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return ListTile(
                    onTap: () => onPickLanguage?.call(),
                    title: Text(language.name.capitalize),
                    trailing: IconButton(
                      icon: Icon(language.isDownloaded ? Icons.delete : Icons.download),
                      onPressed: () {
                        if (language.isDownloaded) {
                          ref.read(offlineLanguagesProvider.notifier).deleteLanguage(language.code);
                        } else {
                          ref.read(offlineLanguagesProvider.notifier).downloadLanguage(language.code);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
