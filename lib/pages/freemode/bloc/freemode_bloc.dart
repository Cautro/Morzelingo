import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:morzelingo/pages/authorization/bloc/authorization_bloc.dart';
import 'package:morzelingo/pages/freemode/models/question_model.dart';
import 'package:morzelingo/pages/freemode/repository/freemode_repository.dart';
import 'package:morzelingo/pages/freemode/service/freemode_service.dart';
part 'freemode_event.dart';
part 'freemode_state.dart';

class FreemodeBloc extends Bloc<FreemodeEvent, FreemodeState> {
  final FreemodeRepository _repository;
  final FreemodeService _service;

  FreemodeBloc({
    required FreemodeRepository repository,
    required FreemodeService service,
}) : _repository = repository, _service = service, super(const FreemodeState()) {

    on<GetEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final String mode = event.mode == FreemodeMode.text ? "text" : "morse";
        final Map<String, String> getQuestion = await _repository.getQuestion(mode);
        final QuestionModel questionData = QuestionModel.fromJson(getQuestion);
        emit(state.copyWith(question: questionData.question, answer: questionData.answer,  mode: event.mode, status: FreemodeStatus.active));
      } catch (e) {
        emit(state.copyWith(success: false, status: FreemodeStatus.error, message: e.toString()));
      }
    });

    on<AnswerEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final bool isRight = _service.answerHandler(event.text, event.answer);
        emit(state.copyWith(success: isRight, message: isRight ? "Правильно" : "Неправильно",));
        emit(state.copyWith(success: null, message: null, isLoading: false));
        if (isRight) { add(GetEvent(mode: state.mode!)); await _repository.completeFreemode(); }
      } catch (e) {
        emit(state.copyWith(success: false, status: FreemodeStatus.error, message: e.toString()));
      }
    });

    on<AudioPlayEvent>((event, emit) async {
      try {
        await _service.playMorse(event.question);
      } catch (e) {
        emit(state.copyWith(success: false, status: FreemodeStatus.error, message: e.toString()));
      }
    });

    on<LeaveEvent>((event, emit) {
      if (state.status != FreemodeStatus.idle) {
        emit(state.copyWith(status: FreemodeStatus.idle));
      }
    });
  }
}