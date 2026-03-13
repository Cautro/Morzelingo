part of 'freemode_bloc.dart';

class FreemodeEvent {}

class TextGetEvent extends FreemodeEvent {}

class TextAnswerEvent extends FreemodeEvent {
  TextAnswerEvent({required this.answer, required this.decoded});
  final decoded;
  final answer;
}

class AudioGetEvent extends FreemodeEvent {}

class AudioAnswerEvent extends FreemodeEvent {
  AudioAnswerEvent({required this.answer, required this.decoded});
  final decoded;
  final answer;
}

class AudioPlayEvent extends FreemodeEvent {
  AudioPlayEvent({required this.isPlaying, required this.question});
  final isPlaying;
  final question;
}