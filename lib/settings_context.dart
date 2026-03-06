import 'package:morzelingo/storage_context.dart';

class SettingsService {
  static Future<void> setDefault() async {
    setWpm(5);
  }
  
  static Future<int> getWpm() async {
    final wpm = await StorageService.getItem("wpm");

    if (wpm == null) {
      await setWpm(5);
      return 5;
    }

    return int.parse(wpm!);
  }

  static Future<void> setWpm(int value) async {
    await StorageService.setItem("wpm", value.toString());
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