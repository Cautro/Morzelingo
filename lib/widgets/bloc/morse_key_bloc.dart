import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'morse_key_event.dart';
import 'morse_key_state.dart';
import '../context/morse_key_context.dart';
import '../../settings_context.dart' hide MorseTiming;

class MorseKeyBloc extends Bloc<MorseKeyEvent, MorseKeyState> {
  final SettingsService settingsService;
  final AudioPlayer _player = AudioPlayer();
  Timer? _pauseTimer;
  Timer? _wordTimer;

  MorseKeyBloc({required this.settingsService}) : super(MorseKeyState.initial()) {
    on<InitMorseKey>(_onInit);
    on<AddDot>(_onAddDot);
    on<AddDash>(_onAddDash);
    on<FinishLetter>(_onFinishLetter);
    on<AddSpace>(_onAddSpace);
    on<ClearMorse>(_onClear);
    on<BackspacePressed>(_onBackspace);
    on<TapDownEvent>((e, emit) => emit(state.copyWith(isPressed: true)));
    on<TapUpEvent>((e, emit) => emit(state.copyWith(isPressed: false)));
  }

  Future<void> _onInit(InitMorseKey event, Emitter<MorseKeyState> emit) async {
    emit(state.copyWith(loading: true));
    _player.setReleaseMode(ReleaseMode.stop);

    try {
      final lang = await SettingsService.getLang();
      final wpm = await SettingsService.getWpm();
      final timing = MorseTiming(wpm);

      final morseMap = (lang == 'ru') ? morseToTextRu : morseToTextEn;

      emit(state.copyWith(
        morseMap: morseMap,
        timing: timing,
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> _onAddDot(AddDot event, Emitter<MorseKeyState> emit) async {
    await _player.play(AssetSource('sounds/dot.wav'));
    _addSymbol('•', emit);
  }

  Future<void> _onAddDash(AddDash event, Emitter<MorseKeyState> emit) async {
    await _player.play(AssetSource('sounds/dash.wav'));
    _addSymbol('—', emit);
  }

  void _addSymbol(String symbol, Emitter<MorseKeyState> emit) {
    final newMorse = state.currentMorse + symbol;
    emit(state.copyWith(currentMorse: newMorse));

    _pauseTimer?.cancel();
    _wordTimer?.cancel();
    final int letterPauseMs = state.timing.letterPause;
    _pauseTimer = Timer(Duration(milliseconds: letterPauseMs * 4), () {
      add(FinishLetter());
    });
  }

  Future<void> _onFinishLetter(FinishLetter event, Emitter<MorseKeyState> emit) async {
    final letter = state.morseMap[state.currentMorse];
    String newDecoded = state.decodedText;
    if (letter != null) {
      newDecoded = newDecoded + letter;
      emit(state.copyWith(decodedText: newDecoded));
    }

    emit(state.copyWith(currentMorse: ''));

    _wordTimer?.cancel();
    final int wordPauseMs = state.timing.wordPause;
    final int letterPauseMs = state.timing.letterPause;
    _wordTimer = Timer(Duration(milliseconds: wordPauseMs), () {
      add(AddSpace());
    });
  }

  Future<void> _onAddSpace(AddSpace event, Emitter<MorseKeyState> emit) async {
    if (state.decodedText.isNotEmpty && !state.decodedText.endsWith(' ')) {
      final updated = '${state.decodedText} ';
      emit(state.copyWith(decodedText: updated));
    }
  }

  Future<void> _onClear(ClearMorse event, Emitter<MorseKeyState> emit) async {
    _pauseTimer?.cancel();
    _wordTimer?.cancel();
    emit(state.copyWith(currentMorse: '', decodedText: ''));
  }

  Future<void> _onBackspace(BackspacePressed event, Emitter<MorseKeyState> emit) async {
    if (state.decodedText.isNotEmpty) {
      final s = state.decodedText;
      final newDecoded = s.substring(0, s.length - 1);
      emit(state.copyWith(decodedText: newDecoded));
    }
  }

  @override
  Future<void> close() {
    _pauseTimer?.cancel();
    _wordTimer?.cancel();
    _player.dispose();
    return super.close();
  }
}