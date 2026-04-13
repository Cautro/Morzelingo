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

class MorseTiming {
  final int dot;
  final int dash;
  final int symbolPause;
  final int letterPause;
  final int wordPause;

  MorseTiming._({
    required this.dot,
    required this.dash,
    required this.symbolPause,
    required this.letterPause,
    required this.wordPause,
  });

  factory MorseTiming.fromWpm(int wpm) {
    final safeWpm = wpm.clamp(5, 20);
    final dot = (1200 / safeWpm).round();

    return MorseTiming._(
      dot: dot,
      dash: dot * 3,
      symbolPause: dot,
      letterPause: dot * 3,
      wordPause: dot * 7,
    );
  }
}