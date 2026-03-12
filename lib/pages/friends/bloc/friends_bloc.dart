import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/friends/context/friends_context.dart';

part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState>{
  FriendsBloc() : super(FriendsInitial()) {
    on<GetFriendsEvent>((event, emit) async {
      List _friends = await FriendsContext().getData();
      emit(FriendsListState(friends: _friends));
    });
    on<AddFriendEvent>((event, emit) async {
      Map _data = await FriendsContext().addHandler(event.code);
      emit(AddFriendState(message: _data["message"], success: _data["success"]));

      List _friends = await FriendsContext().getData();
      emit(FriendsListState(friends: _friends));
    });
    on<DeleteFriendEvent>((event, emit) async {
      Map _data = await FriendsContext().deleteHandler(event.username);
      emit(DeleteFriendState(message: _data["message"], success: _data["success"]));

      List _friends = await FriendsContext().getData();
      emit(FriendsListState(friends: _friends));
    });
  }
}