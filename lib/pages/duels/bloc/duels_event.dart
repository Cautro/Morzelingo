part of 'duels_bloc.dart';

abstract class DuelsEvent extends Equatable {
  const DuelsEvent();

  @override
  List<Object?> get props => [];
}

class CreateDuelEvent extends DuelsEvent {
  const CreateDuelEvent();
}

class JoinDuelEvent extends DuelsEvent {
  const  JoinDuelEvent();
}

class GetStatusEvent extends DuelsEvent {
  const GetStatusEvent();
}

class GetTasksEvent extends DuelsEvent {
  const GetTasksEvent();
}

class AnswerEvent extends DuelsEvent {
  const AnswerEvent({required this.answer});
  final String answer;

  @override
  List<Object?> get props => [answer];
}

class LeaveEvent extends DuelsEvent {
  const LeaveEvent();
}

class CompleteEvent extends DuelsEvent {
  const CompleteEvent();
}

class PlayMorseEvent extends DuelsEvent {
  const PlayMorseEvent({required this.question});
  final String question;

  @override
  List<Object?> get props => [question];
}