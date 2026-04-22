part of 'morse_key_bloc.dart';

class MorseKeyState extends Equatable {
  final MorseTiming? timing;
  final String decodedText;
  final String currentMorse;
  final bool isPressed;
  final Map<String, String> morseMap;
  final bool error;
  final String message;

  const MorseKeyState({
    this.currentMorse = "",
    this.isPressed = false,
    this.timing,
    this.decodedText = "",
    this.morseMap = MorseAlphabet.en,
    this.error = false,
    this.message = "",
  });

  MorseKeyState copyWith({
    String? decodedText,
    String? currentMorse,
    bool? isPressed,
    MorseTiming? timing,
    Map<String, String>? morseMap,
    bool? error,
    String? message,
  }) {
    return MorseKeyState(
      currentMorse: currentMorse ?? this.currentMorse,
      decodedText: decodedText ?? this.decodedText,
      isPressed: isPressed ?? this.isPressed,
      timing: timing ?? this.timing,
      morseMap: morseMap ?? this.morseMap,
      error: error ?? this.error,
      message: message ?? this.message
    );
  }

  @override
  List<Object?> get props => [decodedText, currentMorse, isPressed, timing, morseMap, error, message];

}
