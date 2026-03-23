import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/duels/repository/duels_repository.dart';
import 'package:morzelingo/pages/duels/service/duels_service.dart';
import 'package:morzelingo/settings_context.dart';
part 'duels_event.dart';
part 'duels_state.dart';

class DuelsBloc extends Bloc<DuelsEvent, DuelsState> {
  DuelsBloc() : super(DuelsInitial()) {
    on<CreateDuelEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final createData = await DuelsRepository().createDuel();
      emit(state.copyWith(isLoading: false, duelId: createData["id"], status: createData["status"]));
    });
    on<GetStatusEvent>((event, emit) async {
      if (state.status == "active") {
        return;
      }
      final statusData = await DuelsRepository().getStatus(state.duelId.toString());
      print('${state.status}');
      if (statusData["status"] != "waiting") {
        emit(state.copyWith(status: statusData["status"]));
      }
      if (state.status == "waiting") {
        await Future.delayed(Duration(seconds: 1));
        add(GetStatusEvent());
      }
    });
    on<GetTasksEvent>((event, emit) async {
      String? lang = await SettingsService.getLang();
      final TasksData = await DuelsRepository().getTasks(state.duelId.toString(), lang);
      emit(state.copyWith(tasks: TasksData["questions"]));
      emit(state.copyWith(answer: await DuelsService().getAnswer(state.tasks[state.currentQuestion]["question"], state.tasks[state.currentQuestion]["type"])));
      emit(state.copyWith(status: "playing"));
      print('gandony${state.tasks}');
      print('${state.currentQuestion}');
      print('${state.answer}');
    });
    on<AnswerEvent>((event, emit) async {
      bool _success = await DuelsService().answerHandler(event.answer, state.answer.toString());
      int _score = await DuelsService().scoreHandler(event.answer, state.answer.toString());
      print('${_success}');
      emit(state.copyWith(message: _success ? "Правильно!" : "Неправильно!", success: _success));
      if (_success) {
        emit(state.copyWith(currentQuestion: state.currentQuestion + 1, score: state.score + _score));
        emit(state.copyWith(answer: await DuelsService().getAnswer(state.tasks[state.currentQuestion]["question"], state.tasks[state.currentQuestion]["type"])));
      }
      print('score: ${state.score}');
      emit(state.copyWith(message: null, success: null));
    });
  }
}