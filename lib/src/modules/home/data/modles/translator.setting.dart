import 'package:isar_community/isar.dart';
part 'translator.setting.g.dart';
@Collection()
class TranslatorSetting {
  String? sourceLangCode;
  String? targetLangCode;
  TranslatorSetting();
  final Id id = 0; 
}
