import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../modules/bookmarks/data/datasource/bookmark.local.datasource.dart';
import '../../modules/bookmarks/data/datasource/bookmarks.local.datasource.impl.dart';
import '../../modules/bookmarks/data/repositories/bookmarks.repository.impl.dart';
import '../../modules/bookmarks/domain/repositories/bookmarks_repository.dart';
import '../../modules/bookmarks/domain/usecases/get_bookmarks.dart';
import '../../modules/bookmarks/domain/usecases/remove_bookmark.dart';
import '../../modules/bookmarks/domain/usecases/save_bookmark.dart';
import '../../modules/home/data/datasources/translation_local_data_source.dart';
import '../../modules/home/data/datasources/translation_service_data_source.dart';
import '../../modules/home/data/repository/translation.repo.impl.dart';
import '../../modules/home/domain/repositories/translation_repository.dart';
import '../../modules/home/domain/usecases/get_translation_settings.dart';
import '../../modules/home/domain/usecases/save_translation_settings.dart';
import '../../modules/home/domain/usecases/translate_text.dart';
import '../../modules/languages/data/datasources/language_model_data_source.dart';
import '../../modules/languages/data/repositories/offline_language_repository_impl.dart';
import '../../modules/languages/domain/repositories/offline_language_repository.dart';
import '../../modules/languages/domain/usecases/delete_language.dart';
import '../../modules/languages/domain/usecases/download_language.dart';
import '../../modules/languages/domain/usecases/get_offline_languages.dart';
import '../../modules/setting/data/datasources/settings_local_data_source.dart';
import '../../modules/setting/data/repositories/setting.repository.dart';
import '../../modules/setting/domain/repositories/setting.repo.dart';
import '../../modules/setting/domain/usecases/change_theme.dart';
import '../../modules/setting/domain/usecases/get_settings.dart';

/// Application composition root. Infrastructure implementations are wired to domain
/// contracts here and nowhere in the presentation layer.
final appBoxProvider = Provider<Box<String>>(
  (ref) => throw UnimplementedError('Override appBoxProvider at startup.'),
);

final bookmarksLocalDataSourceProvider = Provider<BookmarksLocalDataSource>(
  (ref) => BookmarksLocalDataSourceImpl(ref.watch(appBoxProvider)),
);
final bookmarksRepositoryProvider = Provider<BookmarksRepository>(
  (ref) => BookmarksRepositoryImpl(ref.watch(bookmarksLocalDataSourceProvider)),
);
final getBookmarksProvider = Provider<GetBookmarks>(
  (ref) => GetBookmarks(ref.watch(bookmarksRepositoryProvider)),
);
final saveBookmarkProvider = Provider<SaveBookmark>(
  (ref) => SaveBookmark(ref.watch(bookmarksRepositoryProvider)),
);
final removeBookmarkProvider = Provider<RemoveBookmark>(
  (ref) => RemoveBookmark(ref.watch(bookmarksRepositoryProvider)),
);

final translationLocalDataSourceProvider = Provider<TranslationLocalDataSource>(
  (ref) => HiveTranslationLocalDataSource(ref.watch(appBoxProvider)),
);
final translationServiceDataSourceProvider =
    Provider<TranslationServiceDataSource>(
      (ref) => const MlKitTranslationServiceDataSource(),
    );
final translationRepositoryProvider = Provider<TranslationRepository>(
  (ref) => TranslationRepositoryImpl(
    ref.watch(translationLocalDataSourceProvider),
    ref.watch(translationServiceDataSourceProvider),
  ),
);
final getTranslationSettingsProvider = Provider<GetTranslationSettings>(
  (ref) => GetTranslationSettings(ref.watch(translationRepositoryProvider)),
);
final saveTranslationSettingsProvider = Provider<SaveTranslationSettings>(
  (ref) => SaveTranslationSettings(ref.watch(translationRepositoryProvider)),
);
final translateTextProvider = Provider<TranslateText>(
  (ref) => TranslateText(ref.watch(translationRepositoryProvider)),
);

final offlineLanguageRepositoryProvider = Provider<OfflineLanguageRepository>((
  ref,
) {
  return OfflineLanguageRepositoryImpl(
    ref.watch(languageModelDataSourceProvider),
  );
});
final languageModelDataSourceProvider = Provider<LanguageModelDataSource>(
  (ref) => MlKitLanguageModelDataSource(),
);
final getOfflineLanguagesProvider = Provider<GetOfflineLanguages>(
  (ref) => GetOfflineLanguages(ref.watch(offlineLanguageRepositoryProvider)),
);
final downloadLanguageProvider = Provider<DownloadLanguage>(
  (ref) => DownloadLanguage(ref.watch(offlineLanguageRepositoryProvider)),
);
final deleteLanguageProvider = Provider<DeleteLanguage>(
  (ref) => DeleteLanguage(ref.watch(offlineLanguageRepositoryProvider)),
);

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>(
  (ref) => HiveSettingsLocalDataSource(ref.watch(appBoxProvider)),
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider)),
);
final getSettingsProvider = Provider<GetSettings>(
  (ref) => GetSettings(ref.watch(settingsRepositoryProvider)),
);
final changeThemeProvider = Provider<ChangeTheme>(
  (ref) => ChangeTheme(ref.watch(settingsRepositoryProvider)),
);
