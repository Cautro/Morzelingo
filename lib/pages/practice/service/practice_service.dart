import 'package:audioplayers/audioplayers.dart';
import 'package:morzelingo/main.dart';

import '../../../settings_context.dart';
import '../bloc/practice_bloc.dart';
import '../models/morse_model.dart';

class PracticeService {

  PracticeType stringToType(String type) {
    switch (type) {
      case "text":
        return PracticeType.text;
      case "audio":
        return PracticeType.audio;
      case "morse":
        return PracticeType.morse;
      default:
        return PracticeType.text;
    }
  }

  String typeToString(PracticeType type) {
    switch (type) {
      case PracticeType.text:
        return "text";
      case PracticeType.audio:
        return "audio";
      case PracticeType.morse:
        return "morse";
      default:
        return "text";
    }
  }

  List<SymbolUpdate> calculateStats(
      String correctAnswer,
      String userAnswer,
      ) {
    correctAnswer = correctAnswer.toUpperCase();
    userAnswer = userAnswer.toUpperCase();

    Map<String, SymbolUpdate> stats = {};

    int maxLength = correctAnswer.length > userAnswer.length
        ? correctAnswer.length
        : userAnswer.length;

    for (int i = 0; i < maxLength; i++) {
      String? correctChar =
      i < correctAnswer.length ? correctAnswer[i] : null;
      String? userChar =
      i < userAnswer.length ? userAnswer[i] : null;

      // если буква была в правильном ответе
      if (correctChar != null) {
        stats.putIfAbsent(
          correctChar,
              () => SymbolUpdate(symbol: correctChar),
        );
      }

      if (correctChar != null && userChar == correctChar) {
        stats[correctChar]!.correct++;
      } else {
        // ошибка
        if (correctChar != null) {
          stats[correctChar]!.wrong++;
        }
      }
    }

    return stats.values.toList();
  }

  Map<String, String> morseToLetter = {};

  Future<String> _decodeMorse(String morseCode) async {
    String? lang = await SettingsService.getLang();
    morseToLetter = lang == "en" ? MorseModels.morseToLetterEN : MorseModels.morseToLetterRU;
    return morseCode.split('  ').map((word) {
      return word.split(' ').map((char) {
        return morseToLetter[char] ?? '';
      }).join('');
    }).join(' ');
  }

  bool checkAnswer(String text, String answer) {
    if (text.isEmpty || answer.isEmpty) {
      throw Except("Текст пуст");
    }
    return text.toUpperCase().trim() == answer.toUpperCase().trim();
  }

  Future<void> playMorseAudio(question) async {
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
        // если пробел, это конец буквы или слова
        await Future.delayed(Duration(milliseconds: timing.letterPause));
      }

      // пауза между символами (если это не последний символ и не пробел)
      if (i < question.length - 1 && question[i + 1] != ' ' && char != ' ') {
        await Future.delayed(Duration(milliseconds: timing.symbolPause));
      }
    }

    player.dispose();
  }

  Future<List> getAnswersForLetters(List questions) async {
    for (int i = 0; i < questions.length; i++) {

      if (questions[i]["type"] == "text") {
        questions[i]["answer"] = questions[i]["question"];
      }
      if (questions[i]["type"] == "morse" || questions[i]["type"] == "audio") {
        questions[i]["answer"] = await _decodeMorse(questions[i]["question"].toString());
      }

    }

    return questions;
  }

}

class SymbolUpdate {
  final String symbol;
  int correct;
  int wrong;

  SymbolUpdate({
    required this.symbol,
    this.correct = 0,
    this.wrong = 0,
  });

  Map<String, dynamic> toJson() => {
    "symbol": symbol,
    "correct": correct,
    "wrong": wrong,
  };
}