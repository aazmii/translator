import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_translator/src/core/di/providers.dart';
import 'package:go_translator/src/core/db/hive.dart';

import '../data/model/setting.model.dart';

final settingsStreamProvider = StreamProvider<AppSetting?>((ref) async* {
  final box = ref.watch(appBoxProvider);

  final initial = box.get(HiveDb.appSettingKey);
  yield initial == null ? null : AppSetting.fromJson(initial);

  await for (final event in box.watch(key: HiveDb.appSettingKey)) {
    final value = event.value;
    if (value is String) {
      yield AppSetting.fromJson(value);
    } else {
      yield null;
    }
  }
});

final settingsProvider = AsyncNotifierProvider<SettingProvider, AppSetting>(SettingProvider.new);

class SettingProvider extends AsyncNotifier<AppSetting> {
  @override
  Future<AppSetting> build() async {
    final stream = ref.watch(settingsStreamProvider);

    return stream.when(
      data: (data) => data ?? AppSetting(),
      loading: () => AppSetting(),
      error: (_, __) => AppSetting(),
    );
  }
}
