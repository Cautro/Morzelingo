import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/api/response_model.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/freemode/repository/freemode_repository.dart';

import '../../../fakes/fake_api_client.dart';
import '../../../helpers/test_bootstrap.dart';

ResponseModel<dynamic> freemodeResponse(
  dynamic json, {
  int statusCode = 200,
}) {
  return ResponseModel<dynamic>(statusCode: statusCode, json: json);
}

void main() {
  group('FreemodeRepository', () {
    late Map<String, ResponseModel<dynamic>> getResponses;
    late Map<String, ResponseModel<dynamic>> postResponses;
    late FakeApiClient client;
    late FreemodeRepository repository;

    setUp(() {
      initializeTestEnvironment(<String, Object>{'lang': 'en'});
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
      repository = FreemodeRepository(client);
    });

    test('should return first freemode question from response', () async {
      getResponses['/api/freemode?mode=text&lang=en&count=1'] =
          freemodeResponse(<String, dynamic>{
            'questions': <Map<String, dynamic>>[
              <String, dynamic>{'question': 'Q1', 'answer': 'A1'},
            ],
          });

      final Map<String, String> question = await repository.getQuestion('text');

      expect(question, <String, String>{'question': 'Q1', 'answer': 'A1'});
      expect(
        client.getRequests.single.endpoint,
        '/api/freemode?mode=text&lang=en&count=1',
      );
    });

    test('should throw ServerException when getQuestion response is invalid', () async {
      getResponses['/api/freemode?mode=text&lang=en&count=1'] =
          freemodeResponse(<String, dynamic>{'message': 'error'}, statusCode: 500);

      await expectLater(
        repository.getQuestion('text'),
        throwsA(isA<ServerException>()),
      );
    });

    test('should complete freemode when response status is valid', () async {
      postResponses['/api/freemode/complete'] = freemodeResponse(
        <String, dynamic>{'ok': true},
      );

      await repository.completeFreemode();

      expect(client.postRequests.single.endpoint, '/api/freemode/complete');
    });

    test('should throw ServerException when complete response is invalid', () async {
      postResponses['/api/freemode/complete'] = freemodeResponse(
        <String, dynamic>{'message': 'error'},
        statusCode: 500,
      );

      await expectLater(
        repository.completeFreemode(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
