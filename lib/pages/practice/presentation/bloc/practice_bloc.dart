import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/practice/domain/entities/question.dart';
import 'package:morzelingo/pages/practice/data/repositories/practice_repository.dart';
import '../../../../core/logger/logger.dart';
import '../../../../core/morse/play_morse.dart';
import '../../domain/entities/question_types.dart';
import '../../domain/services/practice_service.dart';
part 'practice_event.dart';
part 'practice_state.dart';

class PracticeBloc extends Bloc<PracticeEvent, PracticeState>{
  final PracticeRepository _repository;
  final PracticeService _service;
  PracticeBloc({required PracticeRepository repository, required PracticeService service}) :
        _repository = repository, _service = service, super(const PracticeState()) {

    on<GetPracticeEvent>((event, emit) async {
      try {
        final List<Question> getData = await _repository.getPracticeQuestion(event.id);
        final Question task = getData[state.index];
        emit(state.copyWith(status: PracticeStatus.active, tasks: getData, answer: task.answer, question: task.question, type: task.type, id: event.id));
        AppLogger.d(getData);
      } on AppException catch (e) {
        AppLogger.e(e);
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      } catch (e) {
        emit(state.copyWith(success: false, message: "Неизвестная ошибка"));
        emit(state.copyWith(success: null));
      }
    });

    on<GetLettersEvent>((event, emit) async {
      try {
        final List<Question> getData = await _repository.getLetterQuestion();
        final Question task = getData[state.index];
        emit(state.copyWith(isLetter: true, status: PracticeStatus.active, tasks: getData, answer: task.answer, question: task.question, type: task.type));
        AppLogger.d(getData);
      } on AppException catch (e) {
        AppLogger.e(e);
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      } catch (e) {
        emit(state.copyWith(success: false, message: "Неизвестная ошибка"));
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
            final Question task = state.tasks![state.index + 1];
            emit(state.copyWith(
              index: state.index + 1,
              isLast: (state.index + 2 == state.tasks!.length),
              question: task.question,
              answer: task.answer,
              type: task.type,
              success: true,
              message: "Правильно"
            ));
            emit(state.copyWith(success: null));
          }
        } else {
          emit(state.copyWith(success: false, message: "Неправильно"));
          emit(state.copyWith(success: null));
        }

      } on AppException catch (e) {
        AppLogger.e(e);
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      } catch (e) {
        emit(state.copyWith(success: false, message: "Неизвестная ошибка"));
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
      } on AppException catch (e) {
        AppLogger.e(e);
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      } catch (e) {
        emit(state.copyWith(success: false, message: "Неизвестная ошибка"));
        emit(state.copyWith(success: null));
      }
    });

    on<LeaveEvent>((event, emit) {
      try {
        emit(state.copyWith(status: PracticeStatus.leave));
      } on AppException catch (e) {
        AppLogger.e(e);
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      } catch (e) {
        emit(state.copyWith(success: false, message: "Неизвестная ошибка"));
        emit(state.copyWith(success: null));
      }
    });

    on<PlayMorseEvent>((event, emit) async {
      try {
        await PlayMorse().playMorseAudio(state.question);
      } on AppException catch (e) {
        AppLogger.e(e);
        emit(state.copyWith(success: false, message: e.toString()));
        emit(state.copyWith(success: null));
      } catch (e) {
        emit(state.copyWith(success: false, message: "Неизвестная ошибка"));
        emit(state.copyWith(success: null));
      }
    });
  }
}