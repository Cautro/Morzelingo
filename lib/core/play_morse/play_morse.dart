import 'package:audioplayers/audioplayers.dart';
import 'package:morzelingo/core/play_morse/morse_timings.dart';
import '../../settings_context.dart';

class PlayMorse {

  Future<void> playMorseAudio(String question) async {
    final player = AudioPlayer();

    final int wpm = await SettingsService.getWpm();
    final timing = MorseTiming.fromWpm(wpm);

    for (int i = 0; i < question.length; i++) {
      final char = question[i];
      if (char == '•') {
        await player.play(AssetSource('sounds/dot.wav'));
        await Future.delayed(Duration(milliseconds: timing.dot));
      } else if (char == '—') {
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

}