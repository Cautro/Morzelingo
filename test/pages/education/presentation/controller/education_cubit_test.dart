import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/education/domain/entities/lesson.dart';
import 'package:morzelingo/pages/education/domain/repositories/education_repository_interface.dart';
import 'package:morzelingo/pages/education/presentation/controller/education_cubit.dart';
import 'package:morzelingo/pages/education/presentation/controller/education_state.dart';

import '../../../../helpers/test_bootstrap.dart';

class FakeEducationRepository implements IEducationRepository {
  Lesson? lesson;
  List<Lesson> completedLessons = <Lesson>[];
  Object? lessonError;
  Object? completedLessonsError;

  @override
  Future<Lesson> getLesson() async {
    if (lessonError != null) {
      throw lessonError!;
    }
    if (lesson == null) {
      throw StateError('lesson is not configured');
    }
    return lesson!;
  }

  @override
  Future<List<Lesson>> getCompletedLessons() async {
    if (completedLessonsError != null) {
      throw completedLessonsError!;
    }
    return completedLessons;
  }
}

void main() {
  group('EducationCubit', () {
    late FakeEducationRepository repository;
    late EducationCubit cubit;
    late List<EducationState> states;
    late StreamSubscription<EducationState> subscription;

    setUp(() {
      initializeTestEnvironment(<String, Object>{'lang': 'ru'});
      repository = FakeEducationRepository();
      cubit = EducationCubit(repository: repository);
      states = <EducationState>[];
      subscription = cubit.stream.listen(states.add);
    });

    tearDown(() async {
      await subscription.cancel();
      await cubit.close();
    });

    test('should emit loaded states when repository returns lesson data', () async {
      repository.lesson = Lesson(
        id: 1,
        title: 'Lesson 1',
        theory: 'theory',
        xp_reward: 10,
      );
      repository.completedLessons = <Lesson>[
        Lesson(id: 1, title: 'Lesson 1', theory: 'theory', xp_reward: 10),
      ];

      await cubit.getData();
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].lesson?.id, 1);
      expect(states[0].completedLessons, hasLength(1));
      expect(states[0].lang, 'ru');
      expect(states[0].isLoading, isTrue);
      expect(states[1].lesson?.id, 1);
      expect(states[1].lang, 'ru');
      expect(states[1].isLoading, isFalse);
    });

    test('should emit error states when repository throws AppException', () async {
      repository.lessonError = const ServerException('server error');

      await cubit.getData();
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].success, isFalse);
      expect(states[0].message, 'server error');
      expect(states[0].isLoading, isTrue);
      expect(states[1].success, isFalse);
      expect(states[1].message, 'server error');
      expect(states[1].isLoading, isFalse);
    });

    test('should emit error states when repository throws unknown exception', () async {
      repository.lessonError = StateError('boom');

      await cubit.getData();
      await settleAsync();

      expect(states, hasLength(2));
      expect(states[0].success, isFalse);
      expect(states[0].message, isNotEmpty);
      expect(states[0].message, isNot('boom'));
      expect(states[1].success, isFalse);
      expect(states[1].isLoading, isFalse);
    });
  });
}
