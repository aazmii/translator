import 'dart:convert';

import '../../domain/entities/setting.entity.dart';
import '../../domain/entities/theme_profile.dart';

final class SettingsModel {
  const SettingsModel({
    required this.firstRun,
    required this.theme,
    required this.showKeyboardAtStartup,
    required this.textSize,
  });

  final bool firstRun;
  final ThemeProfile theme;
  final bool showKeyboardAtStartup;
  final double textSize;

  factory SettingsModel.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    final storedSize = map['textSize'];
    final textSize = storedSize is num ? storedSize.toDouble() : null;
    return SettingsModel(
      firstRun: map['firstRun'] as bool? ?? true,
      theme: ThemeProfile.values.firstWhere(
        (theme) => theme.name == map['theme'],
        orElse: () => ThemeProfile.light,
      ),
      // Missing in settings saved before this option existed: keep the keyboard.
      showKeyboardAtStartup: map['showKeyboard'] as bool? ?? true,
      // Missing (older settings) or not an offered size: the default.
      textSize: AppSettings.textSizes.contains(textSize) ? textSize! : AppSettings.defaultTextSize,
    );
  }

  factory SettingsModel.fromEntity(AppSettings settings) => SettingsModel(
    firstRun: settings.firstRun,
    theme: settings.theme,
    showKeyboardAtStartup: settings.showKeyboardAtStartup,
    textSize: settings.textSize,
  );

  AppSettings toEntity() => AppSettings(
    firstRun: firstRun,
    theme: theme,
    showKeyboardAtStartup: showKeyboardAtStartup,
    textSize: textSize,
  );

  String toJson() => jsonEncode({
    'firstRun': firstRun,
    'theme': theme.name,
    'showKeyboard': showKeyboardAtStartup,
    'textSize': textSize,
  });
}
