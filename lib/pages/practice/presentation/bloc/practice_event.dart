part of "practice_bloc.dart";

abstract class PracticeEvent extends Equatable {
  const PracticeEvent();
  @override
  List<Object?> get props => [];
}

class GetPracticeEvent extends PracticeEvent {
  final String id;
  const GetPracticeEvent({required this.id});
  @override
  List<Object?> get props => [id];
}

class GetLettersEvent extends PracticeEvent {
  @override
  List<Object?> get props => [];
}

class AnswerEvent extends PracticeEvent {
  final String text;
  const AnswerEvent({required this.text});
  @override
  List<Object?> get props => [text,];
}

class PlayMorseEvent extends PracticeEvent {
  final String text;
  const PlayMorseEvent({required this.text});
  @override
  List<Object?> get props => [text,];
}

class LeaveEvent extends PracticeEvent {
  @override
  List<Object?> get props => [];
}

class CompleteEvent extends PracticeEvent {
  final String id;
  const CompleteEvent({required this.id});
  @override
  List<Object?> get props => [id];
}