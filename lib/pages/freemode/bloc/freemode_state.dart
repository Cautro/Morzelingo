part of 'freemode_bloc.dart';

class FreemodeState {}

class FreemodeInitial extends FreemodeState {}

class TextGetState extends FreemodeState {
  TextGetState({this.question, this.answer, this.success});
  final question;
  final answer;
  final success;
}

class TextAnswerState extends FreemodeState {
  TextAnswerState({required this.success, required this.message});
  final message;
  final success;
}

class AudioGetState extends FreemodeState {
  AudioGetState({this.question, this.answer, this.success});
  final question;
  final answer;
  final success;
}

class AudioAnswerState extends FreemodeState {
  AudioAnswerState({required this.success, required this.message});
  final message;
  final success;
}

class AudioPlayState extends FreemodeState {
  AudioPlayState({required this.isPlaying, required this.success});
  final isPlaying;
  final success;
}