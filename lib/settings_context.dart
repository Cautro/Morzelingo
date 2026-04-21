import 'package:morzelingo/storage_context.dart';

class SettingsService {
  static Future<void> setDefault() async {
    setWpm(10);
    setLang("en");
    setHints(true);
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
    if (value != "ru" && value != "en") {
      await StorageService.setItem("lang", "en");
      return;
    }
    await StorageService.setItem("lang", value.toString());
  }

  static Future<bool> getHints() async {
    final String? hints = await StorageService.getItem("hintsettings");

    if (hints == null) {
      setHints(true);
      return true;
    }

    if (hints == "true") {
      return true;
    } else if (hints == "false") {
      return false;
    }
    print(hints);
    return true;
  }

  static Future<void> setHints(bool value) async {
    await StorageService.setItem("hintsettings", value.toString());
  }

}