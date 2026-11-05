import '../../../../core/usecase/usecase.dart';
import '../repositories/translation_repository.dart';

final class TranslateTextParams {
  const TranslateTextParams({
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
    required this.text,
  });

  final String sourceLanguageCode;
  final String targetLanguageCode;
  final String text;
}

final class TranslateText
    implements UseCase<Future<String>, TranslateTextParams> {
  const TranslateText(this._repository);

  final TranslationRepository _repository;

  @override
  Future<String> call(TranslateTextParams params) {
    final text = params.text.trim();
    if (text.isEmpty) {
      throw ArgumentError.value(params.text, 'text', 'Cannot be empty');
    }
    return _repository.translate(
      sourceLanguageCode: params.sourceLanguageCode,
      targetLanguageCode: params.targetLanguageCode,
      text: text,
    );
  }
}
