import 'package:morzelingo/storage_context.dart';

class SettingsService {
  static Future<void> setDefault() async {
    setWpm(10);
    setLang("en");
  }
  
  static Future<int> getWpm() async {
    final wpm = await StorageService.getItem("wpm");

    if (wpm == null) {
      await setWpm(10);
      return 10;
    }

    return int.parse(wpm);
  }

  static Future<void> setWpm(int value) async {
    await StorageService.setItem("wpm", value.toString());
  }

  static Future<String> getLang() async {
    final lang = await StorageService.getItem("lang");

    if (lang == null) {
      await setLang("en");
      return "en";
    }

    return lang;
  }

  static Future<void> setLang(String value) async {
    if (value != "ru" || value != "en") {
      await StorageService.setItem("lang", "en");
    }
    await StorageService.setItem("lang", value.toString());
  }

}

class MorseTiming {

  final int dot;
  final int dash;
  final int symbolPause;
  final int letterPause;
  final int wordPause;

  MorseTiming(int wpm)
      : dot = (1200 / wpm).round(),
        dash = (1200 / wpm * 3).round(),
        symbolPause = (1200 / wpm).round(),
        letterPause = (1200 / wpm * 3).round(),
        wordPause = (1200 / wpm * 7).round();
}