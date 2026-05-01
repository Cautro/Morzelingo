import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/api/response_model.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/profile/data/repositories/profile_repository.dart';

import '../../../../fakes/fake_api_client.dart';

ResponseModel<dynamic> profileResponse(
  dynamic json, {
  int statusCode = 200,
}) {
  return ResponseModel<dynamic>(statusCode: statusCode, json: json);
}

void main() {
  group('ProfileRepository', () {
    late Map<String, ResponseModel<dynamic>> getResponses;
    late FakeApiClient client;
    late ProfileRepository repository;

    setUp(() {
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
      repository = ProfileRepository(client);
    });

    test('should parse profile response into entity', () async {
      getResponses['/api/profile'] = profileResponse(<String, dynamic>{
        'username': 'alice',
        'email': 'alice@example.com',
        'xp': 30,
        'lesson_done_ru': 1,
        'lesson_done_en': 2,
        'level': 4,
        'coins': 5,
        'streak': 6,
        'referral_code': 'REF',
        'referred_by': 'bob',
        'referred_count': 7,
        'need_xp': 8,
        'symbol_stats': <Map<String, dynamic>>[
          <String, dynamic>{'symbol': 'A', 'correct': 1, 'wrong': 0},
        ],
      });

      final profile = await repository.getData();

      expect(profile.username, 'alice');
      expect(profile.symbol_stats, hasLength(1));
      expect(client.getRequests.single.endpoint, '/api/profile');
      expect(client.getRequests.single.jwt, isTrue);
    });

    test('should throw ServerException when response status is invalid', () async {
      getResponses['/api/profile'] = profileResponse(
        <String, dynamic>{'message': 'error'},
        statusCode: 500,
      );

      await expectLater(repository.getData(), throwsA(isA<ServerException>()));
    });
  });
}
