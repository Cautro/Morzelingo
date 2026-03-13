import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/freemode/context/freemode_context.dart';
part 'freemode_event.dart';
part 'freemode_state.dart';

class FreemodeBloc extends Bloc<FreemodeEvent, FreemodeState> {
  FreemodeBloc() : super(FreemodeInitial()) {
    on<TextGetEvent>((event, emit) async {
      final _data = await FreemodeContext().getTextQuestion();
      emit(TextGetState(answer: _data["answer"], question: _data["question"], success: _data["success"] ));
    });
    on<TextAnswerEvent>((event, emit) async {
     final _data = await FreemodeContext().answerTextHandler(event.decoded, event.answer);
     emit(TextAnswerState(success: _data["success"], message: _data["message"]));

     final _dataGet = await FreemodeContext().getTextQuestion();
     emit(TextGetState(answer: _dataGet["answer"], question: _dataGet["question"], success: _dataGet["success"] ));
    });
    on<AudioGetEvent>((event, emit) async {
      final _data = await FreemodeContext().getAudioQuestion();
      emit(AudioGetState(success: _data["success"], question: _data["question"], answer: _data["answer"]));
    });
    on<AudioAnswerEvent>((event, emit) async {
      final _data = await FreemodeContext().answerAudioHandler(event.decoded, event.answer);
      print('${_data}');
      emit(AudioAnswerState(success: _data["success"], message: _data["message"]));

      final _dataGet = await FreemodeContext().getAudioQuestion();
      emit(AudioGetState(answer: _dataGet["answer"], question: _dataGet["question"], success: _dataGet["success"] ));
    });
    on<AudioPlayEvent>((event, emit) async {
      emit(AudioPlayState(isPlaying: true, success: true));

      await FreemodeContext().playMorse(event.question);

      emit(AudioPlayState(isPlaying: false, success: true));
    });
  }
}