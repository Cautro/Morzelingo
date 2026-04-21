import '../../../../core/exceptions/exceptions.dart';
import '../../../../settings_context.dart';
import '../../../duels/models/morse_models.dart';
import '../entities/question_types.dart';

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

  bool checkAnswer(String text, String answer) {
    if (text.isEmpty || answer.isEmpty) {
      throw Except("Текст пуст");
    }
    return text.toUpperCase().trim() == answer.toUpperCase().trim();
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