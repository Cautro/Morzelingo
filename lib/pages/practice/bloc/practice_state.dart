part of "practice_bloc.dart";

class PracticeState {}

class PracticeInitial extends PracticeState {}

class PracticeGetQuestionState extends PracticeState {
  final data;
  PracticeGetQuestionState({required this.data});
}

class PracticeNextQuestionState extends PracticeState {
  PracticeNextQuestionState({required this.type, this.question, this.answer, this.isLast, this.index});
  final question;
  final answer;
  final type;
  final isLast;
  final index;
}

class PracticeCompleteState extends PracticeState {}

class LettersGetQuestionState extends PracticeState {
  final data;
  LettersGetQuestionState({required this.data});
}

class LettersNextQuestionState extends PracticeState {
  LettersNextQuestionState({required this.type, this.question, this.answer, this.isLast, this.index});
  final question;
  final answer;
  final type;
  final isLast;
  final index;
}

class LettersCompleteState extends PracticeState {}

class PracticeTextAnswerState extends PracticeState {
  PracticeTextAnswerState({required this.success, required this.message});
  final success;
  final message;
}

class PracticeMorseAnswerState extends PracticeState {
  PracticeMorseAnswerState({required this.success, required this.message});
  final success;
  final message;
}