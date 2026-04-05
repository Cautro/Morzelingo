import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:morzelingo/settings_context.dart' hide MorseTiming;
import 'package:morzelingo/widgets/models/morse_key_models.dart';

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
      final Map<String, String> morseMap = lang == "ru" ? morseToTextRu : morseToTextEn;
      emit(state.copyWith(timing: timing, isPressed: false, decodedText: "", currentMorse: "", morseMap: morseMap));
    });

    on<AddDotEvent>((event, emit) async {
      try {
        await _player.play(AssetSource('sounds/dot.wav'));
        add(const AddSymbolEvent(symbol: "•"));
      } catch (e) {
        emit(state.copyWith(message: e.toString(), error: true));
        emit(state.copyWith(error: false));
      }
    });

    on<AddDashEvent>((event, emit) async {
      try {
        await _player.play(AssetSource('sounds/dash.wav'));
        add(const AddSymbolEvent(symbol: "—"));
      } catch (e) {
        emit(state.copyWith(message: e.toString(), error: true));
        emit(state.copyWith(error: false));
      }
    });

    on<AddSymbolEvent>((event, emit) {
      try {
        emit(state.copyWith(currentMorse: state.currentMorse + event.symbol));

        _pauseTimer?.cancel();

        _pauseTimer = Timer(
          Duration(milliseconds: (state.timing!.letterPause * 4).floor()),
                () => add(const FinishLetterEvent())
        );

      } catch (e) {
        emit(state.copyWith(message: e.toString(), error: true));
        emit(state.copyWith(error: false));
      }
    });

    on<FinishLetterEvent>((event, emit) {
      try {
        final String? letter = state.morseMap?[state.currentMorse];
        if (letter != null) {
          emit(state.copyWith(decodedText: state.decodedText + letter));
        }
        emit(state.copyWith(currentMorse: ""));
      } catch (e) {
        emit(state.copyWith(message: e.toString(), error: true));
        emit(state.copyWith(error: false));
      }
    });

    on<AddSpaceEvent>((event, emit) {
      try {
        emit(state.copyWith(decodedText: state.decodedText + " "));
      } catch (e) {
        emit(state.copyWith(message: e.toString(), error: true));
        emit(state.copyWith(error: false));
      }
    });
    on<BackspaceEvent>((event, emit) {
      try {
        if (state.decodedText.isNotEmpty) {
          final text = state.decodedText;
          emit(state.copyWith(decodedText: text.substring(0, text.length - 1)));
        }
      } catch (e) {
        emit(state.copyWith(message: e.toString(), error: true));
        emit(state.copyWith(error: false));
      }
    });
  }

  @override
  Future<void> close() {
    _player.dispose();
    _pauseTimer?.cancel();
    return super.close();
  }
}
