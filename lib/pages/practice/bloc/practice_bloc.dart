import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/practice/models/practice_question_model.dart';
import 'package:morzelingo/pages/practice/repository/practice_repository.dart';
import 'package:morzelingo/pages/practice/service/practice_service.dart';

import '../../../core/logger/logger.dart';
import '../../../core/play_morse/play_morse.dart';
part 'practice_event.dart';
part 'practice_state.dart';

class PracticeBloc extends Bloc<PracticeEvent, PracticeState>{
  final PracticeRepository _repository;
  final PracticeService _service;
  PracticeBloc({required PracticeRepository repository, required PracticeService service}) :
        _repository = repository, _service = service, super(const PracticeState()) {

    on<GetPracticeEvent>((event, emit) async {
      try {
        final List getData = await _repository.getPracticeQuestion(event.id);
        final PracticeQuestionModel task = PracticeQuestionModel.fromJson(getData[state.index]);
        emit(state.copyWith(status: PracticeStatus.active, tasks: getData, answer: task.answer, question: task.question, type: _service.stringToType(task.type)));
        AppLogger.d(getData);
      } catch (e) {
        AppLogger.d(e);
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      }
    });

    on<GetLettersEvent>((event, emit) async {
      try {
        final List getData = await _service.getAnswersForLetters(await _repository.getLetterQuestion());
        final PracticeQuestionModel task = PracticeQuestionModel.fromJson(getData[state.index]);
        emit(state.copyWith(isLetter: true, status: PracticeStatus.active, tasks: getData, answer: task.answer, question: task.question, type: _service.stringToType(task.type)));
        AppLogger.d(getData);
      } catch (e) {
        AppLogger.d(e);
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      }
    });

    on<AnswerEvent>((event, emit) async {
      try {
        AppLogger.d('${state.isLast}');
        final List<SymbolUpdate> stats = _service.calculateStats(state.answer, event.text);
        await _repository.sendStats(stats);
        final bool isRight = _service.checkAnswer(event.text, state.answer);
        if (isRight) {
          if (state.isLast) {
            add(CompleteEvent(id: state.id ?? ""));
            return;
          }
          if (state.index < state.tasks!.length) {
            final PracticeQuestionModel task = PracticeQuestionModel.fromJson(state.tasks![state.index + 1]);
            emit(state.copyWith(
              index: state.index + 1,
              isLast: (state.index + 2 == state.tasks!.length),
              question: task.question,
              answer: task.answer,
              type: _service.stringToType(task.type),
              success: true,
              message: "Правильно"
            ));
            emit(state.copyWith(success: null));
          }
        } else {
          emit(state.copyWith(success: false, message: "Неправильно"));
          emit(state.copyWith(success: null));

        }

      } catch (e) {
        AppLogger.d(e);
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      }
    });

    on<CompleteEvent>((event, emit) async {
      AppLogger.d('complete');
      try {
        if (!state.isLetter) {
          await _repository.completeLesson(event.id);
          emit(state.copyWith(status: PracticeStatus.completed));
        } else {
          emit(state.copyWith(status: PracticeStatus.completed));
        }
      } catch (e) {
        AppLogger.d(e);
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      }
    });

    on<LeaveEvent>((event, emit) {
      try {
        emit(state.copyWith(status: PracticeStatus.leave));
      } catch (e) {
        AppLogger.d(e);
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      }
    });

    on<PlayMorseEvent>((event, emit) async {
      try {
        await PlayMorse().playMorseAudio(state.question);
      } catch (e) {
        AppLogger.d(e);
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      }
    });
  }
}