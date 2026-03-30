import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/practice/context/practice_context.dart';
part 'practice_event.dart';
part 'practice_state.dart';

class PracticeBloc extends Bloc<PracticeEvent, PracticeState>{
  PracticeBloc() : super(PracticeInitial()) {
    on<PracticeGetQuestionEvent>((event, emit) async {
      final data = await PracticeContext().getPracticeQuestion();
      emit(PracticeGetQuestionState(data: data["data"]));
    });
    on<PracticeNextQuestionEvent>((event, emit) async {
      final data = await PracticeContext().nextPracticeQuestion(event.data, event.index, event.isLast);
      if (!data["islast"]) {
        emit(PracticeNextQuestionState(type: data["type"], answer: data["answer"], question: data["question"], index: data["index"], isLast: data["islast"]));
      } else {
        PracticeContext().completeLesson();
        emit(PracticeCompleteState());
      }
    });
    on<LettersGetQuestionEvent>((event, emit) async {
      final data = await PracticeContext().getLetterQuestion(0);
      emit(LettersGetQuestionState(data: data));
    });
    on<LettersNextQuestionEvent>((event, emit) async {
      final data = await PracticeContext().nextLetterQuestion(event.data, event.index, event.isLast);
      if (!data["islast"]) {
        emit(LettersNextQuestionState(type: data["type"], answer: data["answer"], question: data["question"], index: data["index"], isLast: data["islast"]));
      } else {
        emit(LettersCompleteState());
      }
    });
    on<PracticeTextAnswerEvent>((event, emit) async {
      final data = await PracticeContext().answerPracticeTextHandler(event.isLetter, event.decoded, event.answer);
      emit(PracticeTextAnswerState(success: data["success"], message: data["message"]));
    });
    on<PracticeMorseAnswerEvent>((event, emit) async {
      final data = await PracticeContext().answerPracticeMorseHandler(event.isLetter, event.text, event.answer);
      emit(PracticeMorseAnswerState(success: data["success"], message: data["message"]));
    });
    on<PracticePlayMorseEvent>((event, emit) async {
      await PracticeContext().playMorseAudio(event.text);
    });
  }
}