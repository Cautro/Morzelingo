import 'package:equatable/equatable.dart';
import '../../domain/entities/lesson.dart';

class EducationState extends Equatable {
  final Lesson? lesson;
  final List<Lesson>? completedLessons;
  final bool isLoading;
  final bool? success;
  final String message;
  final String lang;

  const EducationState({this.lesson, this.completedLessons, this.isLoading = true, this.success, this.message = "", this.lang = "en"});

  EducationState copyWith({Lesson? lesson, List<Lesson>? completedLessons, bool? isLoading, bool? success, String? message, String? lang}) {
    return EducationState(
        completedLessons: completedLessons ?? this.completedLessons,
        lesson: lesson ?? this.lesson,
        isLoading: isLoading ?? this.isLoading,
        success: success ?? this.success,
        message: message ?? this.message,
        lang: lang ?? this.lang
    );
  }

  @override
  List<Object?> get props => [lesson, completedLessons, isLoading, success, message, lang];
}