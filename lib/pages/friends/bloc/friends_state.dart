part of 'friends_bloc.dart';

class FriendsState {}

class FriendsInitial extends FriendsState {}

class FriendsListState extends FriendsState {
  FriendsListState({required this.friends});
  final List friends;
}

class AddFriendState extends FriendsState {
  AddFriendState({required this.message, required this.success});
  final String message;
  final bool success;
}

class DeleteFriendState extends FriendsState {
  DeleteFriendState({required this.message, required this.success});
  final String message;
  final bool success;
}