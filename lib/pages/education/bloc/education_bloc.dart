import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/education/context/education_context.dart';
part 'education_event.dart';
part 'education_state.dart';

class EducationBloc extends Bloc<EducationEvent, EducationState>{
  EducationBloc() : super(EducationInitial()) {
    on<GetEducationDataEvent>((event, emit) async {
      final data = await EducationContext().getEducationData();
      emit(GetEducationDataState(lessons: data));
    });
    on<GetLessonDataEvent>((event, emit) async {
      final data = await EducationContext().getLessonData();
      emit(GetLessonDataState(done: data["done"], lesson: data["lesson"]));
    });
    on<GetCompletedDataEvent>((event, emit) async {
      final data = await EducationContext().getCompletedLessonsData();
      emit(GetCompletedDataState(completed: data));
    });
  }
}