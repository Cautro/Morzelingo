part of 'friends_bloc.dart';

class FriendsState extends Equatable {
  final List friends;
  final String? message;
  final bool? success;

  const FriendsState({
    this.message,
    this.success,
    this.friends = const [],
  });

  FriendsState copyWith({
    bool? success,
    String? message,
    List? friends
  }) {
    return FriendsState(message: message ?? this.message, success: success ?? this.success, friends: friends ?? this.friends);
  }

  @override
  List<Object?> get props => [message, success, friends];

}