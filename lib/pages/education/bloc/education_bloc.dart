import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/education/context/education_context.dart';
part 'education_event.dart';
part 'education_state.dart';

class EducationBloc extends Bloc<EducationEvent, EducationState>{
  EducationBloc() : super(EducationInitial()) {
    on<GetEducationDataEvent>((event, emit) async {
      final _data = await EducationContext().getEducationData();
      emit(GetEducationDataState(lessons: _data));
    });
    on<GetLessonDataEvent>((event, emit) async {
      final _data = await EducationContext().getLessonData();
      emit(GetLessonDataState(done: _data["done"], lesson: _data["lesson"]));
    });
    on<GetCompletedDataEvent>((event, emit) async {
      final _data = await EducationContext().getCompletedLessonsData();
      emit(GetCompletedDataState(completed: _data));
    });
  }
}