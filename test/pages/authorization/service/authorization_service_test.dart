import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/authorization/service/authorization_service.dart';

void main() {
  group('AuthorizationService', () {
    late AuthorizationService service;

    setUp(() {
      service = AuthorizationService();
    });

    test('should return true when registration data is valid', () async {
      final bool result = await service.checkRegister(
        'user1',
        'secret',
        'secret',
        'user@example.com',
      );

      expect(result, isTrue);
    });

    test('should throw ValidationException when any field is empty', () async {
      final Future<bool> result = service.checkRegister(
        '',
        'secret',
        'secret',
        'user@example.com',
      );

      await expectLater(result, throwsA(isA<ValidationException>()));
    });

    test(
      'should throw ValidationException when passwords do not match',
      () async {
        final Future<bool> result = service.checkRegister(
          'user1',
          'secret',
          'another',
          'user@example.com',
        );

        await expectLater(result, throwsA(isA<ValidationException>()));
      },
    );

    test('should throw ValidationException when login is too short', () async {
      final Future<bool> result = service.checkRegister(
        'usr',
        'secret',
        'secret',
        'user@example.com',
      );

      await expectLater(result, throwsA(isA<ValidationException>()));
    });

    test('should throw ValidationException when email is invalid', () async {
      final Future<bool> result = service.checkRegister(
        'user1',
        'secret',
        'secret',
        'invalid-email',
      );

      await expectLater(result, throwsA(isA<ValidationException>()));
    });
  });
}
