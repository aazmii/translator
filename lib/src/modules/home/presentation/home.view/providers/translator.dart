import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/config/di/providers.dart';
import 'package:go_translator/src/core/usecase/usecase.dart';
import 'package:go_translator/src/modules/home/domain/entities/translation_settings.dart';
import 'package:go_translator/src/modules/home/domain/usecases/translate_text.dart';

final translatorProvider = AsyncNotifierProvider<Translator, TranslatorState>(
  Translator.new,
);

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
    final updated = current.copyWith(
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

  Future<void> translate() async {
    final current = value;
    if (current == null || current.sourceText?.trim().isEmpty != false) return;
    final translatedText = await ref.read(translateTextProvider)(
      TranslateTextParams(
        sourceLanguageCode: current.sourceLanguageCode,
        targetLanguageCode: current.targetLanguageCode,
        text: current.sourceText!,
      ),
    );
    state = AsyncData(current.copyWith(translatedText: translatedText));
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
