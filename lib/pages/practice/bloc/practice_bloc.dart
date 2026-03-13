import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/practice/context/practice_context.dart';
part 'practice_event.dart';
part 'practice_state.dart';

class PracticeBloc extends Bloc<PracticeEvent, PracticeState>{
  PracticeBloc() : super(PracticeInitial()) {
    on<PracticeGetQuestionEvent>((event, emit) async {
      final _data = await PracticeContext().getPracticeQuestion();
      emit(PracticeGetQuestionState(data: _data["data"]));
    });
    on<PracticeNextQuestionEvent>((event, emit) async {
      final _data = await PracticeContext().nextPracticeQuestion(event.data, event.index, event.isLast);
      if (!_data["islast"]) {
        emit(PracticeNextQuestionState(type: _data["type"], answer: _data["answer"], question: _data["question"], index: _data["index"], isLast: _data["islast"]));
      } else {
        PracticeContext().completeLesson();
        emit(PracticeCompleteState());
      }
    });
    on<LettersGetQuestionEvent>((event, emit) async {
      final _data = await PracticeContext().getLetterQuestion(0);
      emit(LettersGetQuestionState(data: _data));
    });
    on<LettersNextQuestionEvent>((event, emit) async {
      final _data = await PracticeContext().nextLetterQuestion(event.data, event.index, event.isLast);
      if (!_data["islast"]) {
        emit(LettersNextQuestionState(type: _data["type"], answer: _data["answer"], question: _data["question"], index: _data["index"], isLast: _data["islast"]));
      } else {
        emit(LettersCompleteState());
      }
    });
    on<PracticeTextAnswerEvent>((event, emit) async {
      final _data = await PracticeContext().answerPracticeTextHandler(event.isLetter, event.decoded, event.answer);
      emit(PracticeTextAnswerState(success: _data["success"], message: _data["message"]));
    });
    on<PracticeMorseAnswerEvent>((event, emit) async {
      final _data = await PracticeContext().answerPracticeMorseHandler(event.isLetter, event.text, event.answer);
      emit(PracticeMorseAnswerState(success: _data["success"], message: _data["message"]));
    });
    on<PracticePlayMorseEvent>((event, emit) async {
      await PracticeContext().playMorseAudio(event.text);
    });
  }
}