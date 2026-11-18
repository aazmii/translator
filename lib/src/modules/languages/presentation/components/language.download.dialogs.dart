import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast, Toast, ToastGravity;
import 'package:go_translator/src/core/extensions/extensions.dart';
import 'package:go_translator/src/modules/languages/domain/entities/language.dart';
import 'package:go_translator/src/modules/languages/presentation/providers/offline.languages.provider.dart';

/// How a download behind [downloadLanguagesWithLoader] ended.
enum LanguageDownloadResult { done, failed, cancelled }

/// Display names joined for a sentence: "Afrikaans" or "Spanish and Afrikaans".
String languageNamesForDisplay(List<Language> languages) =>
    languages.map((language) => language.name.capitalize).join(' and ');

/// Asks before downloading [languages]. True only when the user accepts.
Future<bool> confirmLanguageDownload(BuildContext context, List<Language> languages) async {
  final names = languageNamesForDisplay(languages);
  final verb = languages.length == 1 ? 'needs' : 'need';
  final pronoun = languages.length == 1 ? 'it' : 'them';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Download $names?'),
      content: Text(
        '$names $verb to be downloaded before you can use $pronoun. '
        'This may use mobile data.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Download')),
      ],
    ),
  );
  return confirmed == true;
}

/// Downloads [languages] one after another, over any connection, behind a
/// loader that only its Cancel button can close. ML Kit can't cancel a
/// download, so after Cancel it may still finish in the background; the
/// loader is closed only once, so that late result can't pop another route.
Future<LanguageDownloadResult> downloadLanguagesWithLoader(
  BuildContext context,
  WidgetRef ref,
  List<Language> languages,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  final names = languageNamesForDisplay(languages);
  var loaderOpen = true;
  void close(LanguageDownloadResult result) {
    if (!loaderOpen) return;
    loaderOpen = false;
    navigator.pop(result);
  }

  final loader = showDialog<LanguageDownloadResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Downloading $names…'),
                  const SizedBox(height: 4),
                  Text('This can take a minute.', style: Theme.of(dialogContext).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => close(LanguageDownloadResult.cancelled), child: const Text('Cancel'))],
      ),
    ),
  );

  final notifier = ref.read(offlineLanguagesProvider.notifier);
  Future<void> downloadAll() async {
    try {
      for (final language in languages) {
        if (!loaderOpen) return;
        final ok = await notifier.downloadLanguage(language.code, wifiOnly: false);
        if (!ok) return close(LanguageDownloadResult.failed);
      }
      close(LanguageDownloadResult.done);
    } catch (error, stackTrace) {
      debugPrint('Download of $names failed: $error\n$stackTrace');
      close(LanguageDownloadResult.failed);
    }
  }

  downloadAll();
  return await loader ?? LanguageDownloadResult.cancelled;
}

void showLanguageDownloadFailed(List<Language> languages) {
  Fluttertoast.showToast(
    msg: "Couldn't download ${languageNamesForDisplay(languages)}. Check your connection and try again.",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black87,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
