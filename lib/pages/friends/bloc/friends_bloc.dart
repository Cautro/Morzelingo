import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/friends/repository/friends_repository.dart';

part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState>{
  final FriendsRepository _repository;
  FriendsBloc({required FriendsRepository repository}) : _repository = repository, super(const FriendsState()) {
    on<GetFriendsEvent>((event, emit) async {
      try {
        List friends = await _repository.getData();
        emit(state.copyWith(friends: friends));
      } catch (e) {
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      }
    });
    on<AddFriendEvent>((event, emit) async {
      try {
        String data = await _repository.addHandler(event.code);
        emit(state.copyWith(success: true, message: data));
        emit(state.copyWith(success: null));
        add(GetFriendsEvent());
      } catch (e) {
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      }
    });
    on<DeleteFriendEvent>((event, emit) async {
      try {
        String data = await _repository.deleteHandler(event.username);
        emit(state.copyWith(success: true, message: data));
        emit(state.copyWith(success: null));
        add(GetFriendsEvent());
      } catch (e) {
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      }
    });
  }
} 