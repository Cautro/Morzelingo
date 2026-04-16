part of 'friends_bloc.dart';

abstract class FriendsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetFriendsEvent extends FriendsEvent {}

class AddFriendEvent extends FriendsEvent {
  AddFriendEvent({required this.code});
  final String code;

  @override
  List<Object?> get props => [code];
}

class DeleteFriendEvent extends FriendsEvent {
  DeleteFriendEvent({required this.username});
  final String username;

  @override
  List<Object?> get props => [username];
}