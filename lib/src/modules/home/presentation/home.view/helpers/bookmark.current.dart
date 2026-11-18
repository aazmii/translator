import 'package:flutter/material.dart' show Colors, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast, Toast, ToastGravity;
import 'package:go_translator/src/modules/bookmarks/presentation/providers/bookmarks.controller.dart';

import '../providers/translator.dart';

/// Saves what's on the translator page as a bookmark, for both the source
/// card's star and the translation card's Save button.
///
/// Saves the source text (and the translation, if any). Works before
/// translating (decision 2026-11-17).
///
/// The translation is saved only if it was made from the text now in the
/// box, with the languages it was made in (the selection may have changed
/// since). Otherwise the text is saved alone, in the selected source
/// language.
Future<void> bookmarkCurrentTranslation(WidgetRef ref) async {
  final translation = ref.read(translatorProvider).value;
  final source = translation?.sourceText?.trim();
  if (translation == null || source == null || source.isEmpty) return;
  final origin = translation.translationOrigin;
  final translated = translation.translatedText;
  final matches =
      origin != null && translated != null && translated.isNotEmpty && origin.sourceText.trim() == source;
  try {
    final saved = await ref
        .read(bookmarksControllerProvider.notifier)
        .saveBookmark(
          sourceText: source,
          targetText: matches ? translated : null,
          sourceLanguageCode: matches ? origin.sourceLanguageCode : translation.sourceLanguageCode,
          targetLanguageCode: matches ? origin.targetLanguageCode : null,
        );
    _toast(saved ? 'Bookmarked' : 'Already bookmarked', centre: !saved);
  } catch (error) {
    debugPrint('Bookmark failed: $error');
    _toast('Failed to bookmark');
  }
}

void _toast(String message, {bool centre = true}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: centre ? ToastGravity.CENTER : null,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black87,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
