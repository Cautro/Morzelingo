part of "practice_bloc.dart";

class PracticeEvent {}

class PracticeGetQuestionEvent extends PracticeEvent {}

class PracticeNextQuestionEvent extends PracticeEvent {
  PracticeNextQuestionEvent({required this.data, required this.index, required this.isLast});
  final data;
  final index;
  final isLast;
}

class LettersGetQuestionEvent extends PracticeEvent {}

class LettersNextQuestionEvent extends PracticeEvent {
  LettersNextQuestionEvent({required this.isLast, required this.data, required this.index});
  final data;
  final index;
  final isLast;
}

class PracticeTextAnswerEvent extends PracticeEvent {
  PracticeTextAnswerEvent({required this.decoded, required this.isLetter, required this.answer});
  final decoded;
  final isLetter;
  final answer;
}

class PracticeMorseAnswerEvent extends PracticeEvent {
  PracticeMorseAnswerEvent({required this.text, required this.isLetter, required this.answer});
  final text;
  final isLetter;
  final answer;
}

class PracticePlayMorseEvent extends PracticeEvent {
  PracticePlayMorseEvent({required this.text});
  final text;
}