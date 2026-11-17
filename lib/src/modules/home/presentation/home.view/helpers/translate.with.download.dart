import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/modules/languages/presentation/components/language.download.dialogs.dart';

import '../providers/translator.dart';
import 'translation.toast.dart';

/// Translates, and when a selected language isn't downloaded, offers to
/// download it right here instead of pointing to Offline Languages.
///
/// A language can be selected without its model after it was deleted, on
/// first run (English -> French defaults), or from settings saved before the
/// picker offered downloads.
///
/// Declining the prompt or cancelling the loader shows nothing more: the
/// prompt already said why there's no translation.
Future<void> translateOrOfferDownload(BuildContext context, WidgetRef ref) async {
  final translator = ref.read(translatorProvider.notifier);
  final outcome = await translator.translate();
  if (outcome is! TranslateLanguagesMissing || !context.mounted) {
    showTranslateOutcomeToast(outcome);
    return;
  }

  final missing = outcome.languages;
  if (!await confirmLanguageDownload(context, missing) || !context.mounted) return;

  final result = await downloadLanguagesWithLoader(context, ref, missing);
  switch (result) {
    case LanguageDownloadResult.done:
      showTranslateOutcomeToast(await translator.translate());
    case LanguageDownloadResult.failed:
      showLanguageDownloadFailed(missing);
    case LanguageDownloadResult.cancelled:
      break;
  }
}
