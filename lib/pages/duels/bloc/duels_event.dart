part of 'duels_bloc.dart';

abstract class DuelsEvent extends Equatable {
  const DuelsEvent();

  @override
  List<Object?> get props => [];
}

class CreateDuelEvent extends DuelsEvent {}

class JoinDuelEvent extends DuelsEvent {}

class GetStatusEvent extends DuelsEvent {}

class GetTasksEvent extends DuelsEvent {}

class AnswerEvent extends DuelsEvent {
  AnswerEvent(this.answer);
  final String answer;

  @override
  List<Object?> get props => [answer];
}

class LeaveEvent extends DuelsEvent {}

class CompleteEvent extends DuelsEvent {}

class PlayMorseEvent extends DuelsEvent {
  PlayMorseEvent({required this.question});
  final String question;
}