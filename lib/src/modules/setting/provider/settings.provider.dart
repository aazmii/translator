import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/isar.dart';
import '../data/model/setting.model.dart';

final _settingsStream = db.appSettings.watchObject(0, fireImmediately: true);
final _settingsStreamProvider = StreamProvider((_) => _settingsStream);

typedef AppSettingsNotifier = NotifierProvider<SettingProvider, AppSettingIsar>;
final settingsProvider = AppSettingsNotifier(SettingProvider.new);

class SettingProvider extends Notifier<AppSettingIsar> {
  @override
  AppSettingIsar build() =>
      ref.watch(_settingsStreamProvider).value ?? AppSettingIsar();
}
