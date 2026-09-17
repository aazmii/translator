import 'dart:convert';

import '../../domain/entities/setting.entity.dart';
import '../../domain/entities/theme_profile.dart';

final class SettingsModel {
  const SettingsModel({required this.firstRun, required this.theme});

  final bool firstRun;
  final ThemeProfile theme;

  factory SettingsModel.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return SettingsModel(
      firstRun: map['firstRun'] as bool? ?? true,
      theme: ThemeProfile.values.firstWhere(
        (theme) => theme.name == map['theme'],
        orElse: () => ThemeProfile.light,
      ),
    );
  }

  factory SettingsModel.fromEntity(AppSettings settings) =>
      SettingsModel(firstRun: settings.firstRun, theme: settings.theme);

  AppSettings toEntity() => AppSettings(firstRun: firstRun, theme: theme);

  String toJson() => jsonEncode({'firstRun': firstRun, 'theme': theme.name});
}
