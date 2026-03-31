import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:morzelingo/pages/duels/models/duel_question_model.dart';
import 'package:morzelingo/pages/duels/repository/duels_repository.dart';
import 'package:morzelingo/pages/duels/service/duels_service.dart';
import 'package:morzelingo/settings_context.dart';
part 'duels_event.dart';
part 'duels_state.dart';

class DuelsBloc extends Bloc<DuelsEvent, DuelsState> {
  final DuelsRepository _repository;
  final DuelsService _service;

  DuelsBloc({
    required DuelsRepository repository,
    required DuelsService service,
  })  : _repository = repository, _service = service, super(const DuelsState()) {

    on<CreateDuelEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final Map<String, dynamic> createData = await _repository.createDuel();
        DuelsStatus? status;
        switch (createData["status"].toString()) {
          case "waiting":
            status = DuelsStatus.waiting;
          case "active":
            status = DuelsStatus.active;
          case "playing":
            status = DuelsStatus.playing;
        }
        emit(state.copyWith(isLoading: false, duelId: createData["duel_id"], status: status, lives: 5));
        print('status: ${state.status}');
        if (state.status == DuelsStatus.waiting) {
          add(GetStatusEvent());
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "$e"));
      }
    });

    on<GetStatusEvent>((event, emit) async {
      try {
        final Map<String, dynamic> statusData = await _repository.getStatus(state.duelId.toString());
        print('${state.status}');
        DuelsStatus? status;
        switch (statusData["status"].toString()) {
          case "waiting":
            status = DuelsStatus.waiting;
          case "active":
            status = DuelsStatus.active;
          case "playing":
            status = DuelsStatus.playing;
          case "finished":
            status = DuelsStatus.finished;
        }
        if (status != DuelsStatus.waiting) {
          emit(state.copyWith(status: status, opponent: statusData["player2"] ?? statusData["player1"],));
        }
        if (state.status == DuelsStatus.waiting) {
          await Future.delayed(Duration(seconds: 1));
          add(GetStatusEvent());
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "$e"));
      }

    });

    on<GetTasksEvent>((event, emit) async {
      try {
        String? lang = await SettingsService.getLang();
        final Map<String, dynamic> tasksData = await _repository.getTasks(state.duelId.toString(), lang);
        emit(state.copyWith(tasks: tasksData["questions"]));
        final DuelQuestionModel taskQuestion = DuelQuestionModel.fromJson(state.tasks[state.currentQuestion]);
        emit(state.copyWith(answer: await _service.getAnswer(taskQuestion.question, taskQuestion.type)));
        emit(state.copyWith(status: DuelsStatus.playing));
        print('${state.currentQuestion}');
        print(state.answer);
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "$e"));
      }

    });

    on<PlayMorseEvent>((event, emit) async {
      try {
        await _service.playMorseAudio(
          event.question.toString(),
        );
      } catch (e) {
        emit(state.copyWith(status: DuelsStatus.error, success: false, message: "$e"));
      }
    });

    on<AnswerEvent>((event, emit) async {
      try {
        if (state.lives! <= 1) {
          add(CompleteEvent());
          emit(state.copyWith(success: false, message: "Все жизни израсходованы("));
          return;
        }
        final bool success = await _service.answerHandler(event.answer, state.answer.toString());
        print('$success');
        emit(state.copyWith(message: success ? "Правильно!" : "Неправильно!", success: success));
        if (success) {
          int score = await _service.scoreHandler(event.answer, state.answer.toString());
          emit(state.copyWith(currentQuestion: state.currentQuestion + 1, score: state.score + score));
          final DuelQuestionModel taskQuestion = DuelQuestionModel.fromJson(state.tasks[state.currentQuestion]);
          emit(state.copyWith(answer: await _service.getAnswer(taskQuestion.question, taskQuestion.type)));
          try {
            final Response scoreData = await _repository.updateScore(state.duelId.toString(), state.score);
          } catch (e) {
            emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "$e"));
          }
        }
        if (!success) {
          emit(state.copyWith(lives: state.lives! - 1));
        }
        print('score: ${state.score}');
        emit(state.copyWith(message: null, success: null));
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "$e"));
      }
    });
    on<LeaveEvent>((event, emit) async {
      try {
        final Map data = await _repository.leaveDuel(state.duelId.toString());
        if (data["ok"] == true) {
          emit(state.copyWith(status: DuelsStatus.cancelled));
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "$e"));
      }
    });
    on<CompleteEvent>((event, emit) async {
      try {
        final Map<String, dynamic> data = await _repository.completeDuel(state.duelId.toString());
        emit(state.copyWith(status: DuelsStatus.finished));
        print('FINISHED!!!!!!!!!');
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "$e"));
      }
    });
  }
}