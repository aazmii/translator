import 'theme_profile.dart';

final class AppSettings {
  const AppSettings({this.firstRun = true, this.theme = ThemeProfile.light});

  final bool firstRun;
  final ThemeProfile theme;

  AppSettings copyWith({bool? firstRun, ThemeProfile? theme}) {
    return AppSettings(
      firstRun: firstRun ?? this.firstRun,
      theme: theme ?? this.theme,
    );
  }
}
