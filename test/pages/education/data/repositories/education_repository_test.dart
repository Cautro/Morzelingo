import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/api/response_model.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/education/data/repositories/education_repository.dart';

import '../../../../fakes/fake_api_client.dart';
import '../../../../helpers/test_bootstrap.dart';

ResponseModel<dynamic> educationResponse(
  dynamic json, {
  int statusCode = 200,
}) {
  return ResponseModel<dynamic>(statusCode: statusCode, json: json);
}

void main() {
  group('EducationRepository', () {
    late Map<String, ResponseModel<dynamic>> getResponses;
    late FakeApiClient client;
    late EducationRepository repository;

    setUp(() {
      initializeTestEnvironment(<String, Object>{'lang': 'en'});
      getResponses = <String, ResponseModel<dynamic>>{};
      client = FakeApiClient(
        getHandler: ({required bool jwt, required String endpoint}) async {
          final ResponseModel<dynamic>? response = getResponses[endpoint];
          if (response == null) {
            throw StateError('Missing response for $endpoint');
          }
          return response;
        },
      );
      repository = EducationRepository(client);
    });

    test('should return next lesson when profile and lesson responses are valid', () async {
      getResponses['/api/profile'] = educationResponse(<String, dynamic>{
        'lesson_done_en': 1,
      });
      getResponses['/api/lessons/2/?lang=en'] = educationResponse(
        <String, dynamic>{
          'id': 2,
          'title': 'Lesson 2',
          'theory': 'theory 2',
          'xp_reward': 20,
        },
      );

      final lesson = await repository.getLesson();

      expect(lesson.id, 2);
      expect(lesson.title, 'Lesson 2');
      expect(
        client.getRequests.map((ApiRequest request) => request.endpoint),
        orderedEquals(<String>['/api/profile', '/api/lessons/2/?lang=en']),
      );
    });

    test('should return completed lessons up to completed lessons count', () async {
      getResponses['/api/profile'] = educationResponse(<String, dynamic>{
        'lesson_done_en': 2,
      });
      getResponses['/api/lessons/'] = educationResponse(<Map<String, dynamic>>[
        <String, dynamic>{
          'id': 1,
          'title': 'Lesson 1',
          'theory': 'theory 1',
          'xp_reward': 10,
        },
        <String, dynamic>{
          'id': 2,
          'title': 'Lesson 2',
          'theory': 'theory 2',
          'xp_reward': 20,
        },
        <String, dynamic>{
          'id': 3,
          'title': 'Lesson 3',
          'theory': 'theory 3',
          'xp_reward': 30,
        },
      ]);

      final lessons = await repository.getCompletedLessons();

      expect(lessons, hasLength(2));
      expect(lessons.first.title, 'Lesson 1');
      expect(lessons.last.title, 'Lesson 2');
      expect(
        client.getRequests.map((ApiRequest request) => request.endpoint),
        orderedEquals(<String>['/api/profile', '/api/lessons/']),
      );
    });

    test('should throw ServerException when profile response status is invalid', () async {
      getResponses['/api/profile'] = educationResponse(
        <String, dynamic>{'message': 'error'},
        statusCode: 500,
      );

      await expectLater(repository.getLesson(), throwsA(isA<ServerException>()));
    });
  });
}
