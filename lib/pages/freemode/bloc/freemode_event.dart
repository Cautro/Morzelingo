part of 'freemode_bloc.dart';

class FreemodeEvent {}

class GetEvent extends FreemodeEvent {
  final FreemodeMode mode;
  GetEvent({required this.mode});
}


class AnswerEvent extends FreemodeEvent {
  AnswerEvent({required this.answer, required this.text});
  final text;
  final answer;
}

class AudioPlayEvent extends FreemodeEvent {
  AudioPlayEvent({required this.question});
  final question;
}