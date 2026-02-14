// core/di/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../modules/home/data/repository/translation.repo.impl.dart';
import '../../modules/home/domain/repository/home.repository.dart';
import '../../modules/languages/data/repository/offline.lang.repo.dart';
import '../../modules/languages/domain/repository/offline.translation.reopsitory.dart';
import '../../modules/languages/domain/usecases/get.offline.language.usecase.dart';

final appBoxProvider = Provider<Box<String>>((ref) => throw UnimplementedError());

final translationRepositoryProvider = Provider<TranslationRpository>((ref) {
  final box = ref.watch(appBoxProvider);
  return TranslationRepositoryImpl(box);
});

final offlineLanguageRepositoryProvider = Provider<OfflineLanguageRepository>((ref) {
  return OfflineLanguageRepositoryImpl();
});

final getOfflineLanguageUseCaseProvider = Provider<GetOfflineLanguageUseCase>((ref) {
  final repo = ref.watch(offlineLanguageRepositoryProvider);
  return GetOfflineLanguageUseCase(repo);
});
