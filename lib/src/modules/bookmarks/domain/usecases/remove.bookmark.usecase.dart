import 'package:go_translator/src/core/usecase/usecase.dart';

import '../repositories/bookmarks.reopsitory.dart';

class RemoveTranslationUsecase implements AsyncUseCase<void, String> {
  final BookmarksRepository bookmarkRepository;

  RemoveTranslationUsecase(this.bookmarkRepository);

  @override
  Future<void> call({String? p}) {
    if (p == null) {
      throw ArgumentError.notNull('p');
    }
    return bookmarkRepository.remove(p);
  }
}
