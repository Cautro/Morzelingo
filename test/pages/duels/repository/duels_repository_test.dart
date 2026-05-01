import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/api/response_model.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/duels/repository/duels_repository.dart';

import '../../../fakes/fake_api_client.dart';

ResponseModel<dynamic> duelsResponse(
  dynamic json, {
  int statusCode = 200,
}) {
  return ResponseModel<dynamic>(statusCode: statusCode, json: json);
}

void main() {
  group('DuelsRepository', () {
    late Map<String, ResponseModel<dynamic>> getResponses;
    late Map<String, ResponseModel<dynamic>> postResponses;
    late FakeApiClient client;
    late DuelsRepository repository;

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
      repository = DuelsRepository(client);
    });

    test('should return create duel payload from server', () async {
      postResponses['/api/duel/matchmake'] = duelsResponse(<String, dynamic>{
        'duel_id': 'duel-1',
        'status': 'waiting',
      });

      final Map<String, dynamic> result = await repository.createDuel();

      expect(result['duel_id'], 'duel-1');
      expect(client.postRequests.single.endpoint, '/api/duel/matchmake');
    });

    test('should return duel status payload from server', () async {
      getResponses['/api/duels/status/duel-1'] = duelsResponse(
        <String, dynamic>{'status': 'active'},
      );

      final Map<String, dynamic> result = await repository.getStatus('duel-1');

      expect(result['status'], 'active');
      expect(client.getRequests.single.endpoint, '/api/duels/status/duel-1');
    });

    test('should return duel tasks payload from server', () async {
      postResponses['/api/duels/get-tasks/duel-1?lang=en'] = duelsResponse(
        <String, dynamic>{
          'questions': <Map<String, dynamic>>[
            <String, dynamic>{'question': 'Q1', 'type': 'text'},
          ],
        },
      );

      final Map<String, dynamic> result = await repository.getTasks(
        'duel-1',
        'en',
      );

      expect(result['questions'], hasLength(1));
      expect(
        client.postRequests.single.endpoint,
        '/api/duels/get-tasks/duel-1?lang=en',
      );
    });

    test('should send score update payload to server', () async {
      postResponses['/api/duels/update-score/duel-1'] = duelsResponse(
        <String, dynamic>{'ok': true},
      );

      await repository.updateScore('duel-1', 9);

      expect(
        client.postRequests.single.endpoint,
        '/api/duels/update-score/duel-1',
      );
      expect(
        client.postRequests.single.body,
        <String, dynamic>{'score': 9},
      );
    });

    test('should return completion payload from server', () async {
      postResponses['/api/duels/complete/duel-1'] = duelsResponse(
        <String, dynamic>{'winner': 'alice'},
      );

      final Map<String, dynamic> result = await repository.completeDuel(
        'duel-1',
      );

      expect(result['winner'], 'alice');
      expect(
        client.postRequests.single.endpoint,
        '/api/duels/complete/duel-1',
      );
    });

    test('should return leave duel payload from server', () async {
      postResponses['/api/duels/leave/duel-1'] = duelsResponse(
        <String, dynamic>{'ok': true},
      );

      final Map<dynamic, dynamic> result = await repository.leaveDuel('duel-1');

      expect(result['ok'], isTrue);
      expect(client.postRequests.single.endpoint, '/api/duels/leave/duel-1');
    });

    test('should throw ServerException when create duel status is invalid', () async {
      postResponses['/api/duel/matchmake'] = duelsResponse(
        <String, dynamic>{'message': 'error'},
        statusCode: 500,
      );

      await expectLater(repository.createDuel(), throwsA(isA<ServerException>()));
    });
  });
}
