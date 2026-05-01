import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/friends/bloc/friends_bloc.dart';
import 'package:morzelingo/pages/friends/repository/friends_repository.dart';

import '../../../fakes/fake_api_client.dart';
import '../../../helpers/test_bootstrap.dart';

class FakeFriendsRepository extends FriendsRepository {
  FakeFriendsRepository() : super(FakeApiClient());

  List friendsData = <String>[];
  Object? getDataError;
  Object? addError;
  Object? deleteError;
  int getDataCalls = 0;
  int addCalls = 0;
  int deleteCalls = 0;

  @override
  Future<List> getData() async {
    getDataCalls++;
    if (getDataError != null) {
      throw getDataError!;
    }
    return friendsData;
  }

  @override
  Future<String> addHandler(String code) async {
    addCalls++;
    if (addError != null) {
      throw addError!;
    }
    friendsData = <String>[...friendsData, code];
    return 'added';
  }

  @override
  Future<String> deleteHandler(String username) async {
    deleteCalls++;
    if (deleteError != null) {
      throw deleteError!;
    }
    friendsData = List<String>.from(friendsData)..remove(username);
    return 'deleted';
  }
}

void main() {
  group('FriendsBloc', () {
    late FakeFriendsRepository repository;
    late FriendsBloc bloc;
    late List<FriendsState> states;
    late StreamSubscription<FriendsState> subscription;

    setUp(() {
      initializeTestEnvironment();
      repository = FakeFriendsRepository();
      bloc = FriendsBloc(repository: repository);
      states = <FriendsState>[];
      subscription = bloc.stream.listen(states.add);
    });

    tearDown(() async {
      await subscription.cancel();
      await bloc.close();
    });

    test('should emit friends list when loading succeeds', () async {
      repository.friendsData = <String>['alice', 'bob'];

      bloc.add(GetFriendsEvent());
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].friends, <String>['alice', 'bob']);
      expect(repository.getDataCalls, 1);
    });

    test('should emit success state and refreshed friends when add succeeds', () async {
      repository.friendsData = <String>['alice'];

      bloc.add(AddFriendEvent(code: 'bob'));
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].success, isTrue);
      expect(states[0].message, 'added');
      expect(states[1].friends, <String>['alice', 'bob']);
      expect(states[1].success, isTrue);
      expect(states[1].message, 'added');
      expect(repository.addCalls, 1);
      expect(repository.getDataCalls, 1);
    });

    test('should emit success state and refreshed friends when delete succeeds', () async {
      repository.friendsData = <String>['alice', 'bob'];

      bloc.add(DeleteFriendEvent(username: 'bob'));
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].success, isTrue);
      expect(states[0].message, 'deleted');
      expect(states[1].friends, <String>['alice']);
      expect(states[1].success, isTrue);
      expect(states[1].message, 'deleted');
      expect(repository.deleteCalls, 1);
      expect(repository.getDataCalls, 1);
    });

    test('should emit error state when repository throws AppException', () async {
      repository.addError = const ServerException('cannot add');

      bloc.add(AddFriendEvent(code: 'bob'));
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].success, isFalse);
      expect(states[0].message, 'cannot add');
    });
  });
}
