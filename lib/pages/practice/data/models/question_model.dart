import 'package:morzelingo/pages/practice/domain/entities/question.dart';
import 'package:morzelingo/pages/practice/domain/entities/question_types.dart';
import '../../../../settings_context.dart';
import '../../../duels/models/morse_models.dart';

class PracticeQuestionModel {
  final PracticeType type;
  final String answer;
  final String question;

  PracticeQuestionModel({
    required this.type,
    required this.question,
    required this.answer,
  });

  static PracticeType _typeFromString(String type) {
    switch (type) {
      case "audio": return PracticeType.audio;
      case "morse": return PracticeType.morse;
      default: return PracticeType.text;
    }
  }

  static Future<String> _decodeMorse(String morseCode) async {
    final String? lang = await SettingsService.getLang();
    final Map<String, String> morseToLetter =
    (lang == "en") ? MorseModels.morseToLetterEN : MorseModels.morseToLetterRU;

    return morseCode.split('  ').map((word) {
      return word.split(' ').map((char) {
        return morseToLetter[char] ?? '';
      }).join('');
    }).join(' ');
  }

  static Future<PracticeQuestionModel> fromJsonLetters(Map<String, dynamic> json) async {
    final String typeStr = json["type"] ?? "text";
    final PracticeType type = _typeFromString(typeStr);
    final String questionText = json["question"] ?? "";

    String finalAnswer = "";

    if (typeStr == "text") {
      finalAnswer = questionText;
    } else {
      finalAnswer = await _decodeMorse(questionText);
    }

    return PracticeQuestionModel(
      type: type,
      question: questionText,
      answer: finalAnswer,
    );
  }

  factory PracticeQuestionModel.fromJson(Map<String, dynamic> json) {
    return PracticeQuestionModel(
      type: _typeFromString(json["type"]),
      question: json["question"] ?? "",
      answer: json["answer"] ?? "",
    );
  }

  Question toEntity() {
    return Question(answer: answer, question: question, type: type);
  }
}
