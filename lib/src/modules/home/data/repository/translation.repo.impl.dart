import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../domain/repository/home.repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<String?> translateText(OnDeviceTranslator translator, String text) {
    return translator.translateText(text);
  }
  
  @override
  Future saveSourceLanguage(String code) {
    // TODO: implement saveSourceLanguage
    throw UnimplementedError();
  }
  
  @override
  Future saveTargetLanguage(String code) {
    // TODO: implement saveTargetLanguage
    throw UnimplementedError();
  }
  
}
