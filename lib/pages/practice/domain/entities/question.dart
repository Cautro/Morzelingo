import 'package:morzelingo/pages/practice/domain/entities/question_types.dart';

class Question {
  final PracticeType type;
  final String question;
  final String answer;

  Question({required this.answer, required this.question, required this.type});
}