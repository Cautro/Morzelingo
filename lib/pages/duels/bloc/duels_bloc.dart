import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
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
        final Map<String, dynamic> _createData = await _repository.createDuel();
        DuelsStatus? _status;
        switch (_createData["status"].toString()) {
          case "waiting":
            _status = DuelsStatus.waiting;
          case "active":
            _status = DuelsStatus.active;
          case "playing":
            _status = DuelsStatus.playing;
        }
        emit(state.copyWith(isLoading: false, duelId: _createData["duel_id"], status: _status, lives: 5));
        print('status: ${state.status}');
        if (state.status == DuelsStatus.waiting) {
          add(GetStatusEvent());
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "${e}"));
      }
    });
    on<GetStatusEvent>((event, emit) async {
      try {
        final Map<String, dynamic> _statusData = await _repository.getStatus(state.duelId.toString());
        print('${state.status}');
        DuelsStatus? _status;
        switch (_statusData["status"].toString()) {
          case "waiting":
            _status = DuelsStatus.waiting;
          case "active":
            _status = DuelsStatus.active;
          case "playing":
            _status = DuelsStatus.playing;
          case "finished":
            _status = DuelsStatus.finished;
        }
        if (_status != DuelsStatus.waiting) {
          emit(state.copyWith(status: _status, opponent: _statusData["player2"] ?? _statusData["player1"],));
        }
        if (state.status == DuelsStatus.waiting) {
          await Future.delayed(Duration(seconds: 1));
          add(GetStatusEvent());
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "${e}"));
      }

    });
    on<GetTasksEvent>((event, emit) async {
      try {
        String? lang = await SettingsService.getLang();
        final Map<String, dynamic> _tasksData = await _repository.getTasks(state.duelId.toString(), lang);
        emit(state.copyWith(tasks: _tasksData["questions"]));
        emit(state.copyWith(answer: await _service.getAnswer(state.tasks[state.currentQuestion]["question"], state.tasks[state.currentQuestion]["type"])));
        emit(state.copyWith(status: DuelsStatus.playing));
        print('${state.currentQuestion}');
        print('${state.answer}');
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "${e}"));
      }

    });
    on<PlayMorseEvent>((event, emit) async {
      try {
        await _service.playMorseAudio(
          event.question.toString(),
        );
      } catch (e) {
        emit(state.copyWith(status: DuelsStatus.error, success: false, message: "${e}"));
      }
    });
    on<AnswerEvent>((event, emit) async {
      try {
        if (state.lives! <= 1) {
          add(CompleteEvent());
          emit(state.copyWith(success: false, message: "Все жизни израсходованы("));
          return;
        }
        final bool _success = await _service.answerHandler(event.answer, state.answer.toString());
        print('${_success}');
        emit(state.copyWith(message: _success ? "Правильно!" : "Неправильно!", success: _success));
        if (_success) {
          int _score = await _service.scoreHandler(event.answer, state.answer.toString());
          emit(state.copyWith(currentQuestion: state.currentQuestion + 1, score: state.score + _score));
          emit(state.copyWith(answer: await _service.getAnswer(state.tasks[state.currentQuestion]["question"], state.tasks[state.currentQuestion]["type"])));
          try {
            final Response _scoreData = await _repository.updateScore(state.duelId.toString(), state.score);
          } catch (e) {
            emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "${e}"));
          }
        }
        if (!_success) {
          emit(state.copyWith(lives: state.lives! - 1));
        }
        print('score: ${state.score}');
        emit(state.copyWith(message: null, success: null));
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "${e}"));
      }
    });
    on<LeaveEvent>((event, emit) async {
      try {
        final Map _data = await _repository.leaveDuel(state.duelId.toString());
        if (_data["ok"] == true) {
          emit(state.copyWith(status: DuelsStatus.cancelled));
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "${e}"));
      }
    });
    on<CompleteEvent>((event, emit) async {
      try {
        final Map<String, dynamic> _data = await _repository.completeDuel(state.duelId.toString());
        emit(state.copyWith(status: DuelsStatus.finished));
        print('FINISHED!!!!!!!!!');
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "${e}"));
      }
    });
  }
}