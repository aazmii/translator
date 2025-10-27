import 'package:google_mlkit_translation/google_mlkit_translation.dart';

abstract class HomeRepository {
  Future<String?> translateText(OnDeviceTranslator translator, String text);
}
