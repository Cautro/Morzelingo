import 'package:audioplayers/audioplayers.dart';

import '../../../settings_context.dart';
import '../morse_models.dart';

class DuelsService {

  Map<String, String> _morseToLetter = {};

  Future<String> _decodeMorse(String morseCode) async {
    String? lang = await SettingsService.getLang();
    _morseToLetter = lang == "en" ? MorseModels.morseToLetterEN : MorseModels.morseToLetterRU;
    return morseCode.split('  ').map((word) {
      return word.split(' ').map((char) {
        return _morseToLetter[char] ?? '';
      }).join('');
    }).join(' ');
  }

  Future<String> getAnswer(String question, String type) async {
    String answer = "";

    switch (type) {
      case "text":
        answer = question;
        break;

      case "audio":
        answer = await _decodeMorse(question);
        break;

      case "morse":
        answer = await _decodeMorse(question);
        break;
    }
    return answer;
  }


  Future<void> playMorseAudio(String question) async {
    final player = AudioPlayer();
    player.stop();

    final wpm = await SettingsService.getWpm();
    final timing = MorseTiming(wpm);

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

  Future<bool> answerHandler(String answer, String rightAnswer) async {
    print('${answer} ${rightAnswer}');
    bool success = answer.toUpperCase().trim() == rightAnswer.toUpperCase().trim();
    print('ANSWER RIGHT? ${success}');
    return success;
  }

  Future<int> scoreHandler(String answer, String rightAnswer) async {
    int score = 0;
    answer = answer.trim().toUpperCase().toString();
    rightAnswer = rightAnswer.trim().toUpperCase().toString();

    for (int i = 0; i < rightAnswer.length; i++) {
      if (i < answer.length && answer[i] == rightAnswer[i]) {
        score++;
      }
    }
    return score;
  }
}