import 'package:audioplayers/audioplayers.dart';

import '../../../settings_context.dart';

class FreemodeService {

  Future<void> playMorse(String question) async {

    if (question.length < 1) {
      throw Exception("Воспроизводимый текст - пуст");
    }

    final player = AudioPlayer();

    player.stop();

    final wpm = await SettingsService.getWpm();
    final timing = MorseTiming(wpm);

    for (int i = 0; i < question.length; i++) {

      final char = question[i];

      if (char == '.') {
        await player.play(AssetSource('sounds/dot.wav'));
        await Future.delayed(Duration(milliseconds: timing.dot));

      } else if (char == '-') {
        await player.play(AssetSource('sounds/dash.wav'));
        await Future.delayed(Duration(milliseconds: timing.dash));

      } else if (char == ' ') {
        await Future.delayed(Duration(milliseconds: timing.letterPause));
      }

      if (i < question.length - 1 && question[i + 1] != ' ' && char != ' ') {
        await Future.delayed(Duration(milliseconds: timing.symbolPause));
      }
    }

    player.dispose();

  }

  bool answerHandler(String text, String answer) {
    if (text.toUpperCase().trim() == answer.toUpperCase().trim()) {
      return true;
    } else {
      return false;
    }
  }

}