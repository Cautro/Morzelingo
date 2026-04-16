import 'package:flutter/cupertino.dart';
import 'package:morzelingo/pages/education/domain/repositories/education_repository_interface.dart';
import 'package:morzelingo/pages/education/presentation/controller/education_state.dart';

import '../../domain/entities/lesson.dart';

class EducationController extends ChangeNotifier {
  final IEducationRepository _repository;
  EducationState _state = const EducationState();

  EducationController({required IEducationRepository repository}) : _repository = repository;

  EducationState get state => _state;

  Future<void> getLessons() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final Lesson lesson = await _repository.getLesson();
      print('lessontitle: ${lesson.title}');
      _state =_state.copyWith(lesson: lesson);
      print("lesson: ${_state.lesson?.title ?? ""}");
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(message: e.toString(), success: false);
      notifyListeners();
    } finally {
      _state = _state.copyWith(success: null, isLoading: false);
      notifyListeners();
    }
    print("title: ${_state.lesson?.title ?? ""}, theory: ${_state.lesson?.theory ?? ""}");
  }

  Future<void> getCompletedLessons() async {
    try {
      final List completedLessons = await _repository.getCompletedLessons();
      print('list: ${completedLessons}');
      _state =_state.copyWith(completedLessons: completedLessons);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(message: e.toString(), success: false);
      notifyListeners();
    } finally {
      _state = _state.copyWith(success: null, isLoading: false);
      notifyListeners();
    }
  }

}