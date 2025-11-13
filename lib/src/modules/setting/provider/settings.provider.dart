import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/core/di/providers.dart';

import '../data/model/setting.model.dart';

// Stream of app settings from Isar
final settingsStreamProvider = StreamProvider<AppSetting?>((ref) {
  final db = ref.watch(isarProvider);
  return db.appSettings.watchObject(0, fireImmediately: true);
});

// AsyncNotifier for holding current settings
final settingsProvider = AsyncNotifierProvider<SettingProvider, AppSetting>(SettingProvider.new);

class SettingProvider extends AsyncNotifier<AppSetting> {
  @override
  Future<AppSetting> build() async {
    // subscribe to stream changes
    final stream = ref.watch(settingsStreamProvider);

    return stream.when(
      data: (data) => data ?? AppSetting(),
      loading: () => AppSetting(), // fallback initial value
      error: (_, __) => AppSetting(),
    );
  }
}
