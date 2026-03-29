import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:morzelingo/pages/duels/repository/duels_repository.dart';
import 'package:morzelingo/pages/duels/service/duels_service.dart';
import 'package:morzelingo/settings_context.dart';
part 'duels_event.dart';
part 'duels_state.dart';

class DuelsBloc extends Bloc<DuelsEvent, DuelsState> {
  DuelsBloc() : super(DuelsInitial()) {
    on<CreateDuelEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      var _createData;
      try {
        final _data = await DuelsRepository().createDuel();
        _createData = _data;
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "${e}"));
      }
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
    });
    on<GetStatusEvent>((event, emit) async {
      var _statusData;
      try {
        final _data = await DuelsRepository().getStatus(state.duelId.toString());
        _statusData = _data;
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "${e}"));
      }
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
    });
    on<GetTasksEvent>((event, emit) async {
      String? lang = await SettingsService.getLang();
      var _tasksData;
      try {
        final _data = await DuelsRepository().getTasks(state.duelId.toString(), lang);
        _tasksData = _data;
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "${e}"));
      }
      emit(state.copyWith(tasks: _tasksData["questions"]));
      emit(state.copyWith(answer: await DuelsService().getAnswer(state.tasks[state.currentQuestion]["question"], state.tasks[state.currentQuestion]["type"])));
      emit(state.copyWith(status: DuelsStatus.playing));
      print('${state.currentQuestion}');
      print('${state.answer}');
    });
    on<AnswerEvent>((event, emit) async {
      if (state.lives! <= 1) {
        add(CompleteEvent());
        emit(state.copyWith(success: false, message: "Все жизни израсходованы("));
        return;
      }
      bool _success = await DuelsService().answerHandler(event.answer, state.answer.toString());
      print('${_success}');
      emit(state.copyWith(message: _success ? "Правильно!" : "Неправильно!", success: _success));
      if (_success) {
        int _score = await DuelsService().scoreHandler(event.answer, state.answer.toString());
        emit(state.copyWith(currentQuestion: state.currentQuestion + 1, score: state.score + _score));
        emit(state.copyWith(answer: await DuelsService().getAnswer(state.tasks[state.currentQuestion]["question"], state.tasks[state.currentQuestion]["type"])));
        try {
          final Response _scoreData = await DuelsRepository().updateScore(state.duelId.toString(), state.score);
        } catch (e) {
          emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "${e}"));
        }
      }
      if (!_success) {
        emit(state.copyWith(lives: state.lives! - 1));
      }
      print('score: ${state.score}');
      emit(state.copyWith(message: null, success: null));
    });
    on<LeaveEvent>((event, emit) async {
      var _data;
      try {
        final _leaveData = await DuelsRepository().leaveDuel(state.duelId.toString());
        _data = _leaveData;
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "${e}"));
      }
      if (_data["ok"] == true) {
        emit(state.copyWith(status: DuelsStatus.cancelled));
      }
    });
    on<CompleteEvent>((event, emit) async {
      try {
        final Map _data = await DuelsRepository().completeDuel(state.duelId.toString());
      } catch (e) {
        emit(state.copyWith(isLoading: false, status: DuelsStatus.error, success: false, message: "${e}"));
      }
      emit(state.copyWith(status: DuelsStatus.finished));
      print('FINISHED!!!!!!!!!');
    });
  }
}