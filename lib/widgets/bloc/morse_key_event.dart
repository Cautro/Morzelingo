import 'package:equatable/equatable.dart';

abstract class MorseKeyEvent extends Equatable {
  const MorseKeyEvent();
  @override
  List<Object?> get props => [];
}

class InitMorseKey extends MorseKeyEvent {}

class AddDot extends MorseKeyEvent {}

class AddDash extends MorseKeyEvent {}

class FinishLetter extends MorseKeyEvent {}

class AddSpace extends MorseKeyEvent {}

class ClearMorse extends MorseKeyEvent {}

class BackspacePressed extends MorseKeyEvent {}

class TapDownEvent extends MorseKeyEvent {}

class TapUpEvent extends MorseKeyEvent {}