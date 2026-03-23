part of 'duels_bloc.dart';

class DuelsEvent {}

class CreateDuelEvent extends DuelsEvent {}

class JoinDuelEvent extends DuelsEvent {}

class GetStatusEvent extends DuelsEvent {}

class GetTasksEvent extends DuelsEvent {}

class AnswerEvent extends DuelsEvent {
  AnswerEvent(this.answer);
  String answer;
}