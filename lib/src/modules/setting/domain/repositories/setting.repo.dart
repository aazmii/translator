

abstract class SettingRepository {
  Future saveSourceLanguage(String code);
  String get getSourceLanguage;

  void saveTargetLanguage(String code);
  String get getTargetLanguage;
}
