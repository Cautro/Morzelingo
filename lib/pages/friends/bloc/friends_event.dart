part of 'friends_bloc.dart';

class FriendsEvent {}

class GetFriendsEvent extends FriendsEvent {}

class AddFriendEvent extends FriendsEvent {
  AddFriendEvent({required this.code});
  final String code;
}

class DeleteFriendEvent extends FriendsEvent {
  DeleteFriendEvent({required this.username});
  final String username;
}