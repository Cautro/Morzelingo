part of 'freemode_bloc.dart';

abstract class FreemodeEvent extends Equatable {
  const FreemodeEvent();
  @override
  List<Object?> get props => [];
}

class GetEvent extends FreemodeEvent {
  const GetEvent({required this.mode});
  final FreemodeMode mode;

  @override
  List<Object?> get props => [mode];
}

class LeaveEvent extends FreemodeEvent {
  const LeaveEvent();
  @override
  List<Object?> get props => [];
}


class AnswerEvent extends FreemodeEvent {
  const AnswerEvent({required this.answer, required this.text});
  final String text;
  final String answer;

  @override
  List<Object?> get props => [text, answer];
}

class AudioPlayEvent extends FreemodeEvent {
  const AudioPlayEvent({required this.question});
  final String question;

  @override
  List<Object?> get props => [question];
}