import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/setting/domain/entities/theme_profile.dart';
import '../../modules/setting/presentation/providers/settings_provider.dart';

final themeProvider = Provider<ThemeProfile>((ref) {
  return ref.watch(settingsProvider).value?.theme ?? ThemeProfile.light;
});
