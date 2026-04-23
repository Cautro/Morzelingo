import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/education/domain/repositories/education_repository_interface.dart';
import 'package:morzelingo/pages/education/presentation/controller/education_state.dart';
import 'package:morzelingo/settings_context.dart';
import '../../domain/entities/lesson.dart';
import 'package:morzelingo/core/logger/logger.dart';


class EducationCubit extends Cubit<EducationState> {
  final IEducationRepository _repository;

  EducationCubit({required IEducationRepository repository}) : _repository = repository, super(const EducationState());

  Future<void> getData() async {
    emit(state.copyWith(isLoading: true));
    try {
      final String lang = await SettingsService.getLang();
      final Lesson lesson = await _repository.getLesson();
      final List<Lesson> completedLessons = await _repository.getCompletedLessons();

      emit(state.copyWith(lesson: lesson, completedLessons: completedLessons, lang: lang));
    } on AppException catch (e) {
      AppLogger.e(e);
      emit(state.copyWith(message: e.toString(), success: false));
    } catch (e) {
      emit(state.copyWith(message: "Неизвестная ошибка", success: false));
    } finally {
      emit(state.copyWith(success: null, isLoading: false));
    }
  }

}