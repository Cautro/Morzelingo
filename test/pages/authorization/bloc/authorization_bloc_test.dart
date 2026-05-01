import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/authorization/bloc/authorization_bloc.dart';
import 'package:morzelingo/pages/authorization/repository/authorization_repository.dart';
import 'package:morzelingo/pages/authorization/service/authorization_service.dart';

import '../../../fakes/fake_api_client.dart';
import '../../../helpers/test_bootstrap.dart';

class FakeAuthorizationRepository extends AuthorizationRepository {
  FakeAuthorizationRepository() : super(FakeApiClient());

  Map<String, dynamic> loginResult = <String, dynamic>{
    'success': true,
    'message': 'logged in',
  };
  Map<String, dynamic> registerResult = <String, dynamic>{
    'success': true,
    'message': 'registered',
  };
  bool checkLoginedResult = true;
  Object? loginError;
  Object? registerError;
  Object? checkLoginedError;
  int loginCalls = 0;
  int registerCalls = 0;
  int checkLoginedCalls = 0;

  @override
  Future<Map<String, dynamic>> LoginHandler(String login, String password) async {
    loginCalls++;
    if (loginError != null) {
      throw loginError!;
    }
    return loginResult;
  }

  @override
  Future<Map<String, dynamic>> RegisterHandler(
    String login,
    String password,
    String email,
    String code,
  ) async {
    registerCalls++;
    if (registerError != null) {
      throw registerError!;
    }
    return registerResult;
  }

  @override
  Future<bool> checkLogined() async {
    checkLoginedCalls++;
    if (checkLoginedError != null) {
      throw checkLoginedError!;
    }
    return checkLoginedResult;
  }
}

void main() {
  group('AuthorizationBloc', () {
    late FakeAuthorizationRepository repository;
    late AuthorizationBloc bloc;
    late List<AuthorizationState> states;
    late StreamSubscription<AuthorizationState> subscription;

    setUp(() {
      initializeTestEnvironment();
      repository = FakeAuthorizationRepository();
      bloc = AuthorizationBloc(
        repository: repository,
        service: AuthorizationService(),
      );
      states = <AuthorizationState>[];
      subscription = bloc.stream.listen(states.add);
    });

    tearDown(() async {
      await subscription.cancel();
      await bloc.close();
    });

    test('should emit success state when login succeeds', () async {
      repository.loginResult = <String, dynamic>{
        'success': true,
        'message': 'logged in',
      };

      bloc.add(const LoginEvent(login: 'user1', password: 'secret'));
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].status, AuthorizationStatus.success);
      expect(states[0].message, 'logged in');
      expect(repository.loginCalls, 1);
    });

    test('should emit error and idle states when login fails', () async {
      repository.loginError = const ServerException('login failed');

      bloc.add(const LoginEvent(login: 'user1', password: 'secret'));
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].status, AuthorizationStatus.error);
      expect(states[0].message, 'login failed');
      expect(states[1].status, AuthorizationStatus.idle);
      expect(states[1].message, 'login failed');
    });

    test('should emit success state when register succeeds', () async {
      repository.registerResult = <String, dynamic>{
        'success': true,
        'message': 'registered',
      };

      bloc.add(
        const RegisterEvent(
          login: 'user1',
          password: 'secret',
          confirmpassword: 'secret',
          code: 'REF',
          email: 'user@example.com',
        ),
      );
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].status, AuthorizationStatus.success);
      expect(states[0].message, 'registered');
      expect(repository.registerCalls, 1);
    });

    test('should emit error and idle states when register validation fails', () async {
      bloc.add(
        const RegisterEvent(
          login: 'usr',
          password: 'secret',
          confirmpassword: 'secret',
          code: 'REF',
          email: 'invalid-email',
        ),
      );
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].status, AuthorizationStatus.error);
      expect(states[0].message, isNotEmpty);
      expect(states[1].status, AuthorizationStatus.idle);
      expect(states[1].message, isNotNull);
      expect(repository.registerCalls, 0);
    });

    test('should switch mode from login to register', () async {
      bloc.add(const ChangeModeEvent());
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].mode, AuthorizationMode.register);
    });

    test('should emit loading and success states when session is valid', () async {
      repository.checkLoginedResult = true;

      bloc.add(const CheckLoginedEvent());
      await settleAsync();

      expect(states, hasLength(3));
      expect(states[0].isLoading, isTrue);
      expect(states[0].status, AuthorizationStatus.idle);
      expect(states[1].status, AuthorizationStatus.sessionSuccess);
      expect(states[1].isLoading, isTrue);
      expect(states[2].status, AuthorizationStatus.sessionSuccess);
      expect(states[2].isLoading, isFalse);
    });

    test('should only toggle loading when session check fails from idle state', () async {
      repository.checkLoginedError = const UnauthorizedException('unauthorized');

      bloc.add(const CheckLoginedEvent());
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].status, AuthorizationStatus.idle);
      expect(states[0].isLoading, isTrue);
      expect(states[1].status, AuthorizationStatus.idle);
      expect(states[1].isLoading, isFalse);
    });
  });
}
