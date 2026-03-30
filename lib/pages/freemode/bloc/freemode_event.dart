part of 'freemode_bloc.dart';

class FreemodeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetEvent extends FreemodeEvent {
  final FreemodeMode mode;
  GetEvent({required this.mode});

  @override
  List<Object?> get props => [];
}


class AnswerEvent extends FreemodeEvent {
  AnswerEvent({required this.answer, required this.text});
  final String text;
  final String answer;

  @override
  List<Object?> get props => [text, answer];
}

class AudioPlayEvent extends FreemodeEvent {
  AudioPlayEvent({required this.question});
  final String question;

  @override
  List<Object?> get props => [question];
}