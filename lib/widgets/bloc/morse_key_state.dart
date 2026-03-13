import 'package:equatable/equatable.dart';
import '../context/morse_key_context.dart';

class MorseKeyState extends Equatable {
  final Map<String, String> morseMap;
  final String currentMorse;
  final String decodedText;
  final bool isPressed;
  final MorseTiming timing;
  final bool loading;

  const MorseKeyState({
    required this.morseMap,
    required this.currentMorse,
    required this.decodedText,
    required this.isPressed,
    required this.timing,
    required this.loading,
  });

  factory MorseKeyState.initial() {
    return MorseKeyState(
      morseMap: morseToTextEn,
      currentMorse: '',
      decodedText: '',
      isPressed: false,
      timing: MorseTiming(10),
      loading: true,
    );
  }

  MorseKeyState copyWith({
    Map<String, String>? morseMap,
    String? currentMorse,
    String? decodedText,
    bool? isPressed,
    MorseTiming? timing,
    bool? loading,
  }) {
    return MorseKeyState(
      morseMap: morseMap ?? this.morseMap,
      currentMorse: currentMorse ?? this.currentMorse,
      decodedText: decodedText ?? this.decodedText,
      isPressed: isPressed ?? this.isPressed,
      timing: timing ?? this.timing,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [morseMap, currentMorse, decodedText, isPressed, timing.dotMs, loading];
}