import 'package:flutter/material.dart' show Colors;
import 'package:fluttertoast/fluttertoast.dart'
    show Fluttertoast, Toast, ToastGravity;
import 'package:go_translator/src/core/extensions/extensions.dart';

import '../providers/translator.dart';

/// Tells the user why a translation didn't happen. Shows nothing on success.
/// Raw errors are logged by `Translator.translate()`.
void showTranslateOutcomeToast(TranslateOutcome outcome) {
  final message = switch (outcome) {
    TranslateSucceeded() => null,
    TranslateLanguagesMissing(:final languageNames) => _missingMessage(
      languageNames.map((name) => name.capitalize).toList(),
    ),
    TranslateFailed() => "Couldn't translate this text. Please try again.",
  };
  if (message == null) return;
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black87,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

String _missingMessage(List<String> names) {
  if (names.length == 1) {
    return "${names.single} isn't downloaded. "
        'Download it in Offline Languages.';
  }
  return "${names.join(' and ')} aren't downloaded. "
      'Download them in Offline Languages.';
}
