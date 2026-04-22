import 'package:morzelingo/core/morse/morse_alphabet.dart';

import '../../../core/logger/logger.dart';
import '../../../settings_context.dart';

class DuelsService {

  Map<String, String> _morseToLetter = {};

  Future<String> _decodeMorse(String morseCode) async {
    String? lang = await SettingsService.getLang();
    _morseToLetter = MorseAlphabet.forLang(lang);
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

  Future<bool> answerHandler(String answer, String rightAnswer) async {
    AppLogger.d('$answer $rightAnswer');
    bool success = answer.toUpperCase().trim() == rightAnswer.toUpperCase().trim();
    AppLogger.d('ANSWER RIGHT? $success');
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