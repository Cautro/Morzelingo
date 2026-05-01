import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/practice/data/repositories/practice_repository.dart';
import 'package:morzelingo/pages/practice/domain/entities/question.dart';
import 'package:morzelingo/pages/practice/domain/entities/question_types.dart';
import 'package:morzelingo/pages/practice/domain/services/practice_service.dart';
import 'package:morzelingo/pages/practice/presentation/bloc/practice_bloc.dart';

import '../../../../fakes/fake_api_client.dart';
import '../../../../helpers/test_bootstrap.dart';

class FakePracticeRepository extends PracticeRepository {
  FakePracticeRepository() : super(FakeApiClient());

  List<Question> practiceQuestions = <Question>[];
  List<Question> letterQuestions = <Question>[];
  final List<List<SymbolUpdate>> sentStats = <List<SymbolUpdate>>[];
  final List<String> completedLessonIds = <String>[];
  Object? getPracticeError;
  Object? getLettersError;
  Object? sendStatsError;
  Object? completeLessonError;

  @override
  Future<List<Question>> getPracticeQuestion(String id) async {
    if (getPracticeError != null) {
      throw getPracticeError!;
    }
    return practiceQuestions;
  }

  @override
  Future<List<Question>> getLetterQuestion() async {
    if (getLettersError != null) {
      throw getLettersError!;
    }
    return letterQuestions;
  }

  @override
  Future<void> sendStats(List<SymbolUpdate> updates) async {
    if (sendStatsError != null) {
      throw sendStatsError!;
    }
    sentStats.add(updates);
  }

  @override
  Future<void> completeLesson(String id) async {
    if (completeLessonError != null) {
      throw completeLessonError!;
    }
    completedLessonIds.add(id);
  }
}

Question buildQuestion(String question, String answer) {
  return Question(
    question: question,
    answer: answer,
    type: PracticeType.text,
  );
}

void main() {
  group('PracticeBloc', () {
    late FakePracticeRepository repository;
    late PracticeBloc bloc;
    late List<PracticeState> states;
    late StreamSubscription<PracticeState> subscription;

    setUp(() {
      initializeTestEnvironment();
      repository = FakePracticeRepository();
      bloc = PracticeBloc(
        repository: repository,
        service: PracticeService(),
      );
      states = <PracticeState>[];
      subscription = bloc.stream.listen(states.add);
    });

    tearDown(() async {
      await subscription.cancel();
      await bloc.close();
    });

    test('should emit active state when practice questions are loaded', () async {
      repository.practiceQuestions = <Question>[
        buildQuestion('Q1', 'A'),
        buildQuestion('Q2', 'B'),
      ];

      bloc.add(const GetPracticeEvent(id: '7'));
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].status, PracticeStatus.active);
      expect(states[0].question, 'Q1');
      expect(states[0].answer, 'A');
      expect(states[0].tasks, hasLength(2));
      expect(states[0].id, '7');
    });

    test('should emit error state when practice loading fails', () async {
      repository.getPracticeError = const ServerException('load failed');

      bloc.add(const GetPracticeEvent(id: '7'));
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].success, isFalse);
      expect(states[0].message, 'load failed');
    });

    test('should emit active letter state when letter questions are loaded', () async {
      repository.letterQuestions = <Question>[
        buildQuestion('Q1', 'A'),
      ];

      bloc.add(GetLettersEvent());
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].status, PracticeStatus.active);
      expect(states[0].isLetter, isTrue);
      expect(states[0].question, 'Q1');
      expect(states[0].answer, 'A');
    });

    test('should emit error state when letter loading fails', () async {
      repository.getLettersError = const ServerException('letters failed');

      bloc.add(GetLettersEvent());
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].success, isFalse);
      expect(states[0].message, 'letters failed');
    });

    test('should move to next question when answer is correct and not last', () async {
      repository.practiceQuestions = <Question>[
        buildQuestion('Q1', 'A'),
        buildQuestion('Q2', 'B'),
      ];

      bloc.add(const GetPracticeEvent(id: '7'));
      await settleAsync();
      states.clear();

      bloc.add(const AnswerEvent(text: 'A'));
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].index, 1);
      expect(states[0].isLast, isTrue);
      expect(states[0].question, 'Q2');
      expect(states[0].answer, 'B');
      expect(states[0].success, isTrue);
      expect(repository.sentStats, hasLength(1));
      expect(repository.sentStats.first.first.symbol, 'A');
    });

    test('should emit failure state when answer is incorrect', () async {
      repository.practiceQuestions = <Question>[
        buildQuestion('Q1', 'A'),
        buildQuestion('Q2', 'B'),
      ];

      bloc.add(const GetPracticeEvent(id: '7'));
      await settleAsync();
      states.clear();

      bloc.add(const AnswerEvent(text: 'Z'));
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].success, isFalse);
      expect(states[0].message, isNotEmpty);
      expect(states[0].index, 0);
    });

    test('should complete lesson when last answer is correct', () async {
      repository.practiceQuestions = <Question>[
        buildQuestion('Q1', 'A'),
        buildQuestion('Q2', 'B'),
      ];

      bloc.add(const GetPracticeEvent(id: '7'));
      await settleAsync();

      bloc.add(const AnswerEvent(text: 'A'));
      await settleAsync();
      states.clear();

      bloc.add(const AnswerEvent(text: 'B'));
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].status, PracticeStatus.completed);
      expect(repository.completedLessonIds, <String>['7']);
    });

    test('should complete letter mode without calling repository completeLesson', () async {
      repository.letterQuestions = <Question>[
        buildQuestion('Q1', 'A'),
      ];

      bloc.add(GetLettersEvent());
      await settleAsync();
      states.clear();

      bloc.add(const CompleteEvent(id: 'ignored'));
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].status, PracticeStatus.completed);
      expect(repository.completedLessonIds, isEmpty);
    });

    test('should emit leave state on leave event', () async {
      bloc.add(LeaveEvent());
      await settleAsync();

      expect(states, hasLength(1));
      expect(states[0].status, PracticeStatus.leave);
    });
  });
}
