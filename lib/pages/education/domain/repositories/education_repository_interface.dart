import '../entities/lesson.dart';

abstract class IEducationRepository {
  Future<Lesson> getLesson();
  Future<List> getCompletedLessons();
}