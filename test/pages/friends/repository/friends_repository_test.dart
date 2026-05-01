import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/api/response_model.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/friends/repository/friends_repository.dart';

import '../../../fakes/fake_api_client.dart';

ResponseModel<dynamic> friendsResponse(
  dynamic json, {
  int statusCode = 200,
}) {
  return ResponseModel<dynamic>(statusCode: statusCode, json: json);
}

void main() {
  group('FriendsRepository', () {
    late Map<String, ResponseModel<dynamic>> getResponses;
    late Map<String, ResponseModel<dynamic>> postResponses;
    late FakeApiClient client;
    late FriendsRepository repository;

    setUp(() {
      getResponses = <String, ResponseModel<dynamic>>{};
      postResponses = <String, ResponseModel<dynamic>>{};
      client = FakeApiClient(
        getHandler: ({required bool jwt, required String endpoint}) async {
          final ResponseModel<dynamic>? response = getResponses[endpoint];
          if (response == null) {
            throw StateError('Missing GET response for $endpoint');
          }
          return response;
        },
        postHandler: ({
          required bool jwt,
          required String endpoint,
          dynamic body,
        }) async {
          final ResponseModel<dynamic>? response = postResponses[endpoint];
          if (response == null) {
            throw StateError('Missing POST response for $endpoint');
          }
          return response;
        },
      );
      repository = FriendsRepository(client);
    });

    test('should return friends list from response json', () async {
      getResponses['/api/friends'] = friendsResponse(<String, dynamic>{
        'friends': <String>['alice', 'bob'],
      });

      final friends = await repository.getData();

      expect(friends, <String>['alice', 'bob']);
      expect(client.getRequests.single.endpoint, '/api/friends');
    });

    test('should return success message when friend is added', () async {
      postResponses['/api/friends/add'] = friendsResponse(<String, dynamic>{
        'ok': true,
      });

      final String result = await repository.addHandler('REF123');

      expect(result, 'Р”СЂСѓРі РґРѕР±Р°РІР»РµРЅ');
      expect(client.postRequests.single.endpoint, '/api/friends/add');
      expect(
        client.postRequests.single.body,
        <String, dynamic>{'friend': 'REF123'},
      );
    });

    test('should throw ServerException with response message when add fails', () async {
      postResponses['/api/friends/add'] = friendsResponse(
        <String, dynamic>{'message': 'add failed'},
        statusCode: 500,
      );

      await expectLater(
        repository.addHandler('REF123'),
        throwsA(
          isA<ServerException>().having(
            (ServerException exception) => exception.message,
            'message',
            'add failed',
          ),
        ),
      );
    });

    test('should return success message when friend is deleted', () async {
      postResponses['/api/friends/delete'] = friendsResponse(<String, dynamic>{
        'ok': true,
      });

      final String result = await repository.deleteHandler('alice');

      expect(result, 'Р”СЂСѓРі СѓРґР°Р»С‘РЅ');
      expect(client.postRequests.single.endpoint, '/api/friends/delete');
      expect(
        client.postRequests.single.body,
        <String, dynamic>{'friend': 'alice'},
      );
    });
  });
}
