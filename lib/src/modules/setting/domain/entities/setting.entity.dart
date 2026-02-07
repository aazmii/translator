import 'package:go_translator/src/core/domain/entities/theme.profile.dart';

class AppSetting {
  AppSetting({
    this.id = 0,
    this.firstRun,
    this.theme = ThemeProfile.light,
    this.sourceLanguageCode,
    this.targetLanguageCod,
  });

  final int id;

  final bool? firstRun;

  final ThemeProfile theme;
  
  String? sourceLanguageCode, targetLanguageCod;
}
