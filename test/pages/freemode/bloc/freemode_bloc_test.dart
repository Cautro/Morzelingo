import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/freemode/bloc/freemode_bloc.dart';
import 'package:morzelingo/pages/freemode/repository/freemode_repository.dart';
import 'package:morzelingo/pages/freemode/service/freemode_service.dart';

import '../../../fakes/fake_api_client.dart';
import '../../../helpers/test_bootstrap.dart';

class FakeFreemodeRepository extends FreemodeRepository {
  FakeFreemodeRepository() : super(FakeApiClient());

  final List<Map<String, String>> queuedQuestions = <Map<String, String>>[];
  final List<String> requestedModes = <String>[];
  Object? getQuestionError;
  Object? completeError;
  int completeCalls = 0;

  @override
  Future<Map<String, String>> getQuestion(String mode) async {
    requestedModes.add(mode);
    if (getQuestionError != null) {
      throw getQuestionError!;
    }
    if (queuedQuestions.isEmpty) {
      throw StateError('queuedQuestions is empty');
    }
    return queuedQuestions.removeAt(0);
  }

  @override
  Future<void> completeFreemode() async {
    completeCalls++;
    if (completeError != null) {
      throw completeError!;
    }
  }
}

void main() {
  group('FreemodeBloc', () {
    late FakeFreemodeRepository repository;
    late FreemodeBloc bloc;
    late List<FreemodeState> states;
    late StreamSubscription<FreemodeState> subscription;

    setUp(() {
      initializeTestEnvironment();
      repository = FakeFreemodeRepository();
      bloc = FreemodeBloc(
        repository: repository,
        service: FreemodeService(),
      );
      states = <FreemodeState>[];
      subscription = bloc.stream.listen(states.add);
    });

    tearDown(() async {
      await subscription.cancel();
      await bloc.close();
    });

    test('should emit loading and active states when question is loaded', () async {
      repository.queuedQuestions.add(<String, String>{
        'question': 'Q1',
        'answer': 'A1',
      });

      bloc.add(const GetEvent(mode: FreemodeMode.text));
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].isLoading, isTrue);
      expect(states[0].status, FreemodeStatus.idle);
      expect(states[1].question, 'Q1');
      expect(states[1].answer, 'A1');
      expect(states[1].mode, FreemodeMode.text);
      expect(states[1].status, FreemodeStatus.active);
      expect(states[1].isLoading, isTrue);
      expect(repository.requestedModes, <String>['text']);
    });

    test('should emit loading and error states when repository throws AppException', () async {
      repository.getQuestionError = const ServerException('cannot load');

      bloc.add(const GetEvent(mode: FreemodeMode.text));
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].isLoading, isTrue);
      expect(states[1].status, FreemodeStatus.error);
      expect(states[1].success, isFalse);
      expect(states[1].message, 'cannot load');
      expect(states[1].isLoading, isTrue);
    });

    test('should emit success flow and load next question when answer is correct', () async {
      repository.queuedQuestions.addAll(<Map<String, String>>[
        <String, String>{'question': 'Q1', 'answer': 'A1'},
        <String, String>{'question': 'Q2', 'answer': 'A2'},
      ]);

      bloc.add(const GetEvent(mode: FreemodeMode.text));
      await settleAsync();
      states.clear();

      bloc.add(const AnswerEvent(text: ' a1 ', answer: 'A1'));
      await settleAsync();

      expect(states, hasLength(4));
      expect(states[0].success, isTrue);
      expect(states[0].message, isNotEmpty);
      expect(states[0].question, 'Q1');
      expect(states[1].success, isTrue);
      expect(states[1].isLoading, isFalse);
      expect(states[2].isLoading, isTrue);
      expect(states[3].question, 'Q2');
      expect(states[3].answer, 'A2');
      expect(repository.completeCalls, 1);
      expect(repository.requestedModes, <String>['text', 'text']);
    });

    test('should emit failure flow when answer is incorrect', () async {
      repository.queuedQuestions.add(<String, String>{
        'question': 'Q1',
        'answer': 'A1',
      });

      bloc.add(const GetEvent(mode: FreemodeMode.text));
      await settleAsync();
      states.clear();

      bloc.add(const AnswerEvent(text: 'wrong', answer: 'A1'));
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].success, isFalse);
      expect(states[0].message, isNotEmpty);
      expect(states[0].isLoading, isTrue);
      expect(states[1].success, isFalse);
      expect(states[1].isLoading, isFalse);
      expect(repository.completeCalls, 0);
    });

    test('should emit idle state when leave event is added from active state', () async {
      repository.queuedQuestions.add(<String, String>{
        'question': 'Q1',
        'answer': 'A1',
      });

      bloc.add(const GetEvent(mode: FreemodeMode.text));
      await settleAsync();
      states.clear();

      bloc.add(const LeaveEvent());
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].status, FreemodeStatus.idle);
      expect(states[0].isLoading, isTrue);
    });
  });
}
