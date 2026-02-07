import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/entities/theme.profile.dart';
import '../../core/utils/files/paths.dart';
import '../../modules/setting/data/model/setting.model.dart';
import '../../modules/setting/provider/settings.provider.dart';
import '../model/theme.model.dart';

typedef ThemeNotifier = NotifierProvider<ThemeProvider, ThemeProfile>;
final themeProvider = ThemeNotifier(ThemeProvider.new);

class ThemeProvider extends Notifier<ThemeProfile> {
  @override
  ThemeProfile build() => ref.watch(settingsProvider.select((v) => v.value?.theme ?? ThemeProfile.light));

  ThemeProfile get theme => state;

  Future<void> changeTheme(ThemeProfile theme) async =>
      await compute(_changeTheme, _Data(ref.read(settingsProvider).value!, theme));

  Future<void> toggleTheme() async => await changeTheme(state.toggled);
}

void _changeTheme(_Data data) {
  // openDBSync(data.dir);
  data.setting.theme = data.theme;
  // db.writeTxnSync(() => db.appSettings.putSync(data.setting));
}

class _Data {
  _Data(this.setting, this.theme);

  final AppDir dir = appDir;
  final ThemeProfile theme;
  final AppSetting setting;
}
