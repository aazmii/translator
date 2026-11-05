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

  Future<void> toggleTheme() async {
    final current = state.value;
    if (current == null) return;
    await changeTheme(current.theme.toggled);
  }
}
