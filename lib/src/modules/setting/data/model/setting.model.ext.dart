part of 'setting.model.dart';

extension SettingExtension on AppSettingIsar {
  AppSettingIsar copyWith({bool? firstRun, ThemeProfile? theme}) => AppSettingIsar()
    ..firstRun = firstRun ?? this.firstRun
    ..theme = theme ?? this.theme;
}
