import 'theme_profile.dart';

final class AppSettings {
  const AppSettings({
    this.firstRun = true,
    this.theme = ThemeProfile.system,
    this.showKeyboardAtStartup = true,
  });

  final bool firstRun;
  final ThemeProfile theme;

  /// Whether the home screen focuses the source field (opening the keyboard)
  /// when it first opens.
  final bool showKeyboardAtStartup;

  AppSettings copyWith({bool? firstRun, ThemeProfile? theme, bool? showKeyboardAtStartup}) {
    return AppSettings(
      firstRun: firstRun ?? this.firstRun,
      theme: theme ?? this.theme,
      showKeyboardAtStartup: showKeyboardAtStartup ?? this.showKeyboardAtStartup,
    );
  }
}
