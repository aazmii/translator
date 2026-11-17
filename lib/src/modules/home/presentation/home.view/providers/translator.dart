import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/core/usecase/usecase.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation_settings.dart';
import 'package:go_translator/src/modules/home/domain/usecases/translate_text.dart';

final translatorProvider = AsyncNotifierProvider<Translator, TranslatorState>(
  Translator.new,
);

/// What happened when [Translator.translate] ran.
sealed class TranslateOutcome {
  const TranslateOutcome();
}

/// Translated, or there was nothing to translate.
final class TranslateSucceeded extends TranslateOutcome {
  const TranslateSucceeded();
}

/// One or both language models aren't downloaded, so ML Kit wasn't called.
final class TranslateLanguagesMissing extends TranslateOutcome {
  const TranslateLanguagesMissing(this.languageNames);

  /// Names as ML Kit gives them (lower case), source first.
  final List<String> languageNames;
}

/// ML Kit or the model check threw. The raw error is logged.
final class TranslateFailed extends TranslateOutcome {
  const TranslateFailed();
}

/// The source text or a language changed while translating, so the outcome
/// was dropped and the state left as it was.
final class TranslateSuperseded extends TranslateOutcome {
  const TranslateSuperseded();
}

final class TranslatorState {
  const TranslatorState({
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
    this.sourceText,
    this.translatedText,
  });

  final String sourceLanguageCode;
  final String targetLanguageCode;
  final String? sourceText;
  final String? translatedText;

  static const _notProvided = Object();

  TranslatorState copyWith({
    String? sourceLanguageCode,
    String? targetLanguageCode,
    Object? sourceText = _notProvided,
    Object? translatedText = _notProvided,
  }) {
    return TranslatorState(
      sourceLanguageCode: sourceLanguageCode ?? this.sourceLanguageCode,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      sourceText: sourceText == _notProvided
          ? this.sourceText
          : sourceText as String?,
      translatedText: translatedText == _notProvided
          ? this.translatedText
          : translatedText as String?,
    );
  }
}

final class Translator extends AsyncNotifier<TranslatorState> {
  @override
  Future<TranslatorState> build() async {
    final saved = await ref.watch(getTranslationSettingsProvider)(
      const NoParams(),
    );
    final settings =
        saved ??
        const TranslationSettings(
          sourceLanguageCode: 'en',
          targetLanguageCode: 'fr',
        );
    if (saved == null) {
      await ref.read(saveTranslationSettingsProvider)(settings);
    }
    return TranslatorState(
      sourceLanguageCode: settings.sourceLanguageCode,
      targetLanguageCode: settings.targetLanguageCode,
    );
  }

  TranslatorState? get value => state.value;

  Future<void> swapLanguage() async {
    final current = value;
    if (current == null) return;
    final translated = current.translatedText;
    final hasTranslation = translated != null && translated.isNotEmpty;
    // With a translation, exchange the texts too so each stays with its
    // language. Without one, keep the source text and swap languages only.
    final updated = hasTranslation
        ? current.copyWith(
            sourceLanguageCode: current.targetLanguageCode,
            targetLanguageCode: current.sourceLanguageCode,
            sourceText: translated,
            translatedText: current.sourceText,
          )
        : current.copyWith(
            sourceLanguageCode: current.targetLanguageCode,
            targetLanguageCode: current.sourceLanguageCode,
          );
    state = AsyncData(updated);
    await _saveLanguageSettings(updated);
  }

  void setSourceText(String? s) {
    final current = value;
    if (current == null) return;
    state = AsyncData(current.copyWith(sourceText: s));
  }

  /// Translates the source text. ML Kit is only called when both language
  /// models are downloaded: with a model missing it would wait for a download
  /// (forever when offline). On any outcome but success the old translation
  /// is cleared.
  ///
  /// If the source text or either language changes while this waits, the
  /// outcome no longer matches what's on screen: the state is left alone and
  /// [TranslateSuperseded] is returned.
  Future<TranslateOutcome> translate() async {
    final current = value;
    if (current == null || current.sourceText?.trim().isEmpty != false) {
      return const TranslateSucceeded();
    }
    try {
      final getLanguage = ref.read(getLanguageProvider);
      final missing = <String>[];
      for (final code in [
        current.sourceLanguageCode,
        current.targetLanguageCode,
      ]) {
        final language = await getLanguage(code);
        if (language == null) {
          throw StateError('Unknown language code: $code');
        }
        if (!language.isDownloaded) missing.add(language.name);
      }
      if (missing.isNotEmpty) {
        final latest = _latestIfUnchanged(current);
        if (latest == null) return const TranslateSuperseded();
        state = AsyncData(latest.copyWith(translatedText: null));
        return TranslateLanguagesMissing(missing);
      }

      final translatedText = await ref.read(translateTextProvider)(
        TranslateTextParams(
          sourceLanguageCode: current.sourceLanguageCode,
          targetLanguageCode: current.targetLanguageCode,
          text: current.sourceText!,
        ),
      );
      final latest = _latestIfUnchanged(current);
      if (latest == null) return const TranslateSuperseded();
      state = AsyncData(latest.copyWith(translatedText: translatedText));
      return const TranslateSucceeded();
    } catch (error, stackTrace) {
      debugPrint('translate() failed: $error\n$stackTrace');
      final latest = _latestIfUnchanged(current);
      if (latest == null) return const TranslateSuperseded();
      state = AsyncData(latest.copyWith(translatedText: null));
      return const TranslateFailed();
    }
  }

  /// The latest state if its source text and languages still match [started],
  /// otherwise null.
  TranslatorState? _latestIfUnchanged(TranslatorState started) {
    final latest = value;
    if (latest == null) return null;
    final unchanged =
        latest.sourceText == started.sourceText &&
        latest.sourceLanguageCode == started.sourceLanguageCode &&
        latest.targetLanguageCode == started.targetLanguageCode;
    return unchanged ? latest : null;
  }

  Future<void> setSourceLanguage(String code) async {
    final current = value;
    if (current == null) return;
    if (code == current.targetLanguageCode) {
      await swapLanguage();
      return;
    }
    final updated = current.copyWith(sourceLanguageCode: code);
    state = AsyncData(updated);
    await _saveLanguageSettings(updated);
  }

  Future<void> setTargetLanguage(String code) async {
    final current = value;
    if (current == null) return;
    if (code == current.sourceLanguageCode) {
      await swapLanguage();
      return;
    }
    final updated = current.copyWith(targetLanguageCode: code);
    state = AsyncData(updated);
    await _saveLanguageSettings(updated);
  }

  void clear() {
    final current = value;
    if (current == null) return;
    state = AsyncData(current.copyWith(sourceText: null, translatedText: null));
  }

  Future<void> _saveLanguageSettings(TranslatorState value) {
    return ref.read(saveTranslationSettingsProvider)(
      TranslationSettings(
        sourceLanguageCode: value.sourceLanguageCode,
        targetLanguageCode: value.targetLanguageCode,
      ),
    );
  }
}
