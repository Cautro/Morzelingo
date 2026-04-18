import 'package:flutter/cupertino.dart';
import 'package:morzelingo/pages/education/domain/repositories/education_repository_interface.dart';
import 'package:morzelingo/pages/education/presentation/controller/education_state.dart';
import 'package:morzelingo/settings_context.dart';
import '../../domain/entities/lesson.dart';
import 'package:morzelingo/core/logger/logger.dart';


class EducationController extends ChangeNotifier {
  final IEducationRepository _repository;
  EducationState _state = const EducationState();

  EducationController({required IEducationRepository repository}) : _repository = repository;

  EducationState get state => _state;

  Future<void> getData() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final String lang = await SettingsService.getLang();
      final Lesson lesson = await _repository.getLesson();
      final List<Lesson> completedLessons = await _repository.getCompletedLessons();

      _state = _state.copyWith(lesson: lesson, completedLessons: completedLessons, lang: lang);
      notifyListeners();
    } catch (e) {
      appLogger.e(e);
      _state = _state.copyWith(message: e.toString(), success: false);
      notifyListeners();
    } finally {
      _state = _state.copyWith(success: null, isLoading: false);
      notifyListeners();
    }
  }

}