import 'theme_profile.dart';

final class AppSettings {
  const AppSettings({
    this.firstRun = true,
    this.theme = ThemeProfile.system,
    this.showKeyboardAtStartup = true,
    this.textSize = defaultTextSize,
  });

  /// Font sizes offered for the source and translation text.
  static const textSizes = [14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 30.0, 32.0];
  static const defaultTextSize = 18.0;

  final bool firstRun;
  final ThemeProfile theme;

  /// Whether the home screen focuses the source field (opening the keyboard)
  /// when it first opens.
  final bool showKeyboardAtStartup;

  /// Font size of the source and translation text; one of [textSizes].
  final double textSize;

  AppSettings copyWith({bool? firstRun, ThemeProfile? theme, bool? showKeyboardAtStartup, double? textSize}) {
    return AppSettings(
      firstRun: firstRun ?? this.firstRun,
      theme: theme ?? this.theme,
      showKeyboardAtStartup: showKeyboardAtStartup ?? this.showKeyboardAtStartup,
      textSize: textSize ?? this.textSize,
    );
  }
}
