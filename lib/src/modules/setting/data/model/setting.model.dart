import 'dart:convert' show json;

 

import 'package:isar_community/isar.dart';

import '../../../../theme/model/theme.model.dart';

part 'setting.model.ext.dart';
part 'setting.model.g.dart';

@Collection()
class AppSettingIsar {
  AppSettingIsar();

  final Id id = 0;

  bool firstRun = true;

  @Enumerated(EnumType.name)
  ThemeProfile theme = ThemeProfile.dark;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'firstRun': firstRun,
        'theme': theme.name,
        'id': id,
      };

  factory AppSettingIsar.fromJson(String source) =>
      AppSettingIsar.fromRawJson(json.decode(source));

  factory AppSettingIsar.fromRawJson(Map<String, dynamic> json) => AppSettingIsar()
    ..firstRun = json['firstRun'] as bool
    ..theme = ThemeProfile.values.firstWhere(
      (e) => e.name == json['theme'] as String,
      orElse: () => ThemeProfile.dark,
    );

  @override
  String toString() => toRawJson();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettingIsar && other.id == id;
  }

  @Ignore()
  @override
  int get hashCode => id.hashCode;
}
