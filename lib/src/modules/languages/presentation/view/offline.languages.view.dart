import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/core/extensions/extensions.dart';
import 'package:go_translator/src/modules/home/presentation/home.view/providers/translator.dart';
import 'package:go_translator/src/modules/languages/presentation/components/expandabe.search.app.bar.dart';
import 'package:go_translator/src/modules/languages/presentation/providers/offline.languages.provider.dart';

class OfflineLanguagesView extends ConsumerStatefulWidget {
  const OfflineLanguagesView({super.key, required this.title});
  final String title;

  @override
  ConsumerState<OfflineLanguagesView> createState() => _OfflineLanguagesViewState();
}

class _OfflineLanguagesViewState extends ConsumerState<OfflineLanguagesView> {
  String? searchText = '';
  @override
  Widget build(BuildContext context) {
    // TODO: optimize, it's causing spike
    final languages = ref
        .watch(offlineLanguagesProvider)
        .value
        ?.where((l) => l.name.toLowerCase().contains(searchText!.toLowerCase()))
        .toList();
    // final languages = ref.watch(offlineLanguagesProvider).value;
    final downloaded = languages?.where((l) => l.isDownloaded).toList();
    if (languages == null) return Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: ExpandableSearchAppBar(
        title: widget.title,
        onChanged: (value) {
          setState(() => searchText = value);
          // _controller.text = value;
        },
        hintText: '${widget.title}...',
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: languages.length,
          itemBuilder: (context, i) {
            final language = languages[i];
            if (i == 0) {
              return Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Text('Recent Languages', style: TextStyle(color: context.theme.colorScheme.primary)),
                  ListTile(
                    onTap: () => _pickLanguage(context, ref, widget.title, language.code),
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
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Text('Other Languages', style: TextStyle(color: context.theme.colorScheme.primary)),
                  ListTile(
                    onTap: () => _pickLanguage(context, ref, widget.title, language.code),
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
              onTap: () => _pickLanguage(context, ref, widget.title, language.code),
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
    );
  }

  _pickLanguage(BuildContext context, WidgetRef ref, String title, String pickedLanguageCode) {
    {
      if (title.toLowerCase().contains('to')) {
        ref.read(translatorProvider.notifier).setTargetLanguage = pickedLanguageCode;
      } else {
        ref.read(translatorProvider.notifier).setSourceLanguage = pickedLanguageCode;
      }
      context.pop();
    }
  }
}
