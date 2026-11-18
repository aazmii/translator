import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/di/providers.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/setting.entity.dart';
import '../../domain/entities/theme_profile.dart';

final settingsProvider = AsyncNotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

final class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() =>
      ref.watch(getSettingsProvider)(const NoParams());

  Future<void> changeTheme(ThemeProfile theme) async {
    state = AsyncData(await ref.read(changeThemeProvider)(theme));
  }

  Future<void> setKeyboardAtStartup(bool show) async {
    state = AsyncData(await ref.read(setKeyboardAtStartupProvider)(show));
  }

  Future<void> setTextSize(double size) async {
    state = AsyncData(await ref.read(setTextSizeProvider)(size));
  }
}
