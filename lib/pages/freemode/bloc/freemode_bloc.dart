import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        emit(state.copyWith(question: getQuestion["question"], answer: getQuestion["answer"],  mode: event.mode, status: FreemodeStatus.active));
      } catch (e) {
        emit(state.copyWith(success: false, status: FreemodeStatus.error, message: e.toString()));
      }
    });
    on<AnswerEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final bool isRight = _service.answerHandler(event.text, event.answer);
        // await _repository.checkerPractice(isRight);
        await _repository.completeFreemode();
          emit(state.copyWith(success: isRight, message: isRight ? "Правильно" : "Неправильно",));
          emit(state.copyWith(success: null, message: null, isLoading: false));
          if (isRight) { add(GetEvent(mode: state.mode!)); }
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
  }
}