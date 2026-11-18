import 'dart:convert';

import '../../domain/entities/setting.entity.dart';
import '../../domain/entities/theme_profile.dart';

final class SettingsModel {
  const SettingsModel({required this.firstRun, required this.theme, required this.showKeyboardAtStartup});

  final bool firstRun;
  final ThemeProfile theme;
  final bool showKeyboardAtStartup;

  factory SettingsModel.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return SettingsModel(
      firstRun: map['firstRun'] as bool? ?? true,
      theme: ThemeProfile.values.firstWhere(
        (theme) => theme.name == map['theme'],
        orElse: () => ThemeProfile.light,
      ),
      // Missing in settings saved before this option existed: keep the keyboard.
      showKeyboardAtStartup: map['showKeyboard'] as bool? ?? true,
    );
  }

  factory SettingsModel.fromEntity(AppSettings settings) => SettingsModel(
    firstRun: settings.firstRun,
    theme: settings.theme,
    showKeyboardAtStartup: settings.showKeyboardAtStartup,
  );

  AppSettings toEntity() =>
      AppSettings(firstRun: firstRun, theme: theme, showKeyboardAtStartup: showKeyboardAtStartup);

  String toJson() => jsonEncode({'firstRun': firstRun, 'theme': theme.name, 'showKeyboard': showKeyboardAtStartup});
}
