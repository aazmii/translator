part of 'theme.model.dart';

extension ThemeProfileExtension on ThemeProfile {
  ThemeMode get themeMode => switch (this) {
    ThemeProfile.system => ThemeMode.system,
    ThemeProfile.light => ThemeMode.light,
    ThemeProfile.dark => ThemeMode.dark,
  };

  /// The name shown in Settings.
  String get label => switch (this) {
    ThemeProfile.system => 'Device theme',
    ThemeProfile.light => 'Light',
    ThemeProfile.dark => 'Dark',
  };
}
