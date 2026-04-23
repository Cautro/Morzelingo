import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:morzelingo/core/morse/morse_alphabet.dart';
import 'package:morzelingo/settings_context.dart';

import '../../core/morse/morse_timings.dart';

part 'morse_key_event.dart';
part 'morse_key_state.dart';

class MorseKeyBloc extends Bloc<MorseKeyEvent, MorseKeyState> {
  final AudioPlayer _player = AudioPlayer();
  Timer? _pauseTimer;

  MorseKeyBloc() : super(const MorseKeyState()) {
    on<InitMorseKeyEvent>((event, emit) async {
      final int wpm = await SettingsService.getWpm();
      final String lang = await SettingsService.getLang();
      final MorseTiming timing = MorseTiming.fromWpm(wpm);
      final Map<String, String> morseMap = MorseAlphabet.forLang(lang);
      emit(state.copyWith(timing: timing, isPressed: false, decodedText: "", currentMorse: "", morseMap: morseMap));
    });

    on<AddDotEvent>((event, emit) async {
      try {
        await _player.play(AssetSource('sounds/dot.wav'));
        _addSymbol("•", emit);
      } catch (e) {
        emit(state.copyWith(message: e.toString(), error: true));
        emit(state.copyWith(error: false));
      }
    });

    on<AddDashEvent>((event, emit) async {
      try {
        await _player.play(AssetSource('sounds/dash.wav'));
        _addSymbol("—", emit);
      } catch (e) {
        emit(state.copyWith(message: e.toString(), error: true));
        emit(state.copyWith(error: false));
      }
    });

    on<FinishLetterEvent>((event, emit) {
      final String? letter = state.morseMap[state.currentMorse];
      if (letter != null) {
        emit(state.copyWith(decodedText: state.decodedText + letter));
      }

      emit(state.copyWith(currentMorse: ""));
    });

    on<AddSpaceEvent>((event, emit) {
        emit(state.copyWith(decodedText: "${state.decodedText} "));
    });

    on<BackspaceEvent>((event, emit) {
      if (state.decodedText.isNotEmpty) {
        final text = state.decodedText;
        emit(state.copyWith(decodedText: text.substring(0, text.length - 1)));
      }
    });

    on<TapUpEvent>((event, emit) {
      emit(state.copyWith(isPressed: false));
    });

    on<TapDownEvent>((event, emit) {
      emit(state.copyWith(isPressed: true));
    });
  }


  void _addSymbol(String symbol, Emitter<MorseKeyState> emit) {
    emit(state.copyWith(currentMorse: state.currentMorse + symbol));
    _pauseTimer?.cancel();
    _pauseTimer = Timer(
      Duration(milliseconds: state.timing?.letterPause.floor() ?? 500),
          () => add(const FinishLetterEvent()),
    );
  }

  @override
  Future<void> close() {
    _player.dispose();
    _pauseTimer?.cancel();
    return super.close();
  }
}
