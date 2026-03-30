import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/friends/context/friends_context.dart';

part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState>{
  FriendsBloc() : super(FriendsInitial()) {
    on<GetFriendsEvent>((event, emit) async {
      List friends = await FriendsContext().getData();
      emit(FriendsListState(friends: friends));
    });
    on<AddFriendEvent>((event, emit) async {
      Map data = await FriendsContext().addHandler(event.code);
      emit(AddFriendState(message: data["message"], success: data["success"]));

      List friends = await FriendsContext().getData();
      emit(FriendsListState(friends: friends));
    });
    on<DeleteFriendEvent>((event, emit) async {
      Map data = await FriendsContext().deleteHandler(event.username);
      emit(DeleteFriendState(message: data["message"], success: data["success"]));

      List friends = await FriendsContext().getData();
      emit(FriendsListState(friends: friends));
    });
  }
}