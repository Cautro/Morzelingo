part of 'education_bloc.dart';

class EducationState {}

class EducationInitial extends EducationState {}

class GetEducationDataState extends EducationState {
  GetEducationDataState({required this.lessons});
  final lessons;
}

class GetLessonDataState extends EducationState {
  GetLessonDataState({required this.done, required this.lesson});
  final lesson;
  final done;
}

class GetCompletedDataState extends EducationState {
  GetCompletedDataState({required this.completed});
  final completed;
}