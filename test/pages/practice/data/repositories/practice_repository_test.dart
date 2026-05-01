import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/api/response_model.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/practice/data/repositories/practice_repository.dart';
import 'package:morzelingo/pages/practice/domain/services/practice_service.dart';

import '../../../../fakes/fake_api_client.dart';
import '../../../../helpers/test_bootstrap.dart';

ResponseModel<dynamic> practiceResponse(
  dynamic json, {
  int statusCode = 200,
}) {
  return ResponseModel<dynamic>(statusCode: statusCode, json: json);
}

void main() {
  group('PracticeRepository', () {
    late Map<String, ResponseModel<dynamic>> getResponses;
    late Map<String, ResponseModel<dynamic>> postResponses;
    late FakeApiClient client;
    late PracticeRepository repository;

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
      repository = PracticeRepository(client);
    });

    test('should parse practice questions from valid response', () async {
      getResponses['/api/practice/7?lang=en'] = practiceResponse(
        '{"questions":[{"type":"text","question":"Q1","answer":"A1"}]}',
      );

      final questions = await repository.getPracticeQuestion('7');

      expect(questions, hasLength(1));
      expect(questions.first.question, 'Q1');
      expect(questions.first.answer, 'A1');
      expect(client.getRequests.single.endpoint, '/api/practice/7?lang=en');
    });

    test('should parse letter questions using stored letter and language', () async {
      initializeTestEnvironment(<String, Object>{
        'lang': 'en',
        'letter': 'A B',
      });
      postResponses['/api/practice?letters=A%20B&lang=en'] = practiceResponse(
        <String, dynamic>{
          'questions': <Map<String, dynamic>>[
            <String, dynamic>{
              'type': 'audio',
              'question': 'Q1',
              'answer': 'A1',
            },
          ],
        },
      );

      final questions = await repository.getLetterQuestion();

      expect(questions, hasLength(1));
      expect(questions.first.answer, 'A1');
      expect(
        client.postRequests.single.endpoint,
        '/api/practice?letters=A%20B&lang=en',
      );
      expect(client.postRequests.single.body, isNull);
    });

    test('should send stats payload to submit endpoint', () async {
      postResponses['/api/practice/submit'] = practiceResponse(<String, dynamic>{
        'ok': true,
      });

      await repository.sendStats(
        <SymbolUpdate>[SymbolUpdate(symbol: 'A', correct: 2, wrong: 1)],
      );

      expect(client.postRequests.single.endpoint, '/api/practice/submit');
      expect(client.postRequests.single.body, <Map<String, dynamic>>[
        <String, dynamic>{'symbol': 'A', 'correct': 2, 'wrong': 1},
      ]);
    });

    test('should send lesson completion payload with parsed integer id', () async {
      postResponses['/api/complete-lesson'] = practiceResponse(
        <String, dynamic>{'ok': true},
      );

      await repository.completeLesson('12');

      expect(client.postRequests.single.endpoint, '/api/complete-lesson');
      expect(
        client.postRequests.single.body,
        <String, dynamic>{'lesson_id': 12},
      );
    });

    test('should throw ServerException when question response status is invalid', () async {
      getResponses['/api/practice/7?lang=en'] = practiceResponse(
        <String, dynamic>{'message': 'error'},
        statusCode: 500,
      );

      await expectLater(
        repository.getPracticeQuestion('7'),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException when submit response status is invalid', () async {
      postResponses['/api/practice/submit'] = practiceResponse(
        <String, dynamic>{'message': 'error'},
        statusCode: 500,
      );

      await expectLater(
        repository.sendStats(<SymbolUpdate>[SymbolUpdate(symbol: 'A')]),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
