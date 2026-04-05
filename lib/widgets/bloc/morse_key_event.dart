part of 'morse_key_bloc.dart';

abstract class MorseKeyEvent extends Equatable {
  const MorseKeyEvent();
  @override
  List<Object?> get props => [];
}

class InitMorseKeyEvent extends MorseKeyEvent {
  const InitMorseKeyEvent();
}

class AddDotEvent extends MorseKeyEvent {
  const AddDotEvent();
}

class AddDashEvent extends MorseKeyEvent {
  const AddDashEvent();
}

class TapDownEvent extends MorseKeyEvent {
  const TapDownEvent();
}

class TapUpEvent extends MorseKeyEvent {
  const TapUpEvent();
}

class BackspaceEvent extends MorseKeyEvent {
  const BackspaceEvent();
}

class AddSpaceEvent extends MorseKeyEvent {
  const AddSpaceEvent();
}

class FinishLetterEvent extends MorseKeyEvent {
  const FinishLetterEvent();
}

class AddSymbolEvent extends MorseKeyEvent {
  final String symbol;
  const AddSymbolEvent({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}
