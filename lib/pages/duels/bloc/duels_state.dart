part of 'duels_bloc.dart';

enum DuelsStatus {
  idle,
  waiting,
  active,
  playing,
  finished,
  error,
  cancelled,
}

class DuelsState extends Equatable {
  final bool isLoading;
  final String? duelId;
  final DuelsStatus status;
  // idle | waiting | active | playing | submitting | waitingResult | finished | error
  final List<dynamic> tasks;
  final int currentQuestion;
  final String answer;
  final int score;
  final String? winner;
  final String? error;
  final bool? success;
  final String? message;
  final int? lives;
  final String? opponent;

  const DuelsState({
    this.isLoading = false,
    this.duelId,
    this.status = DuelsStatus.idle,
    this.tasks = const [],
    this.answer = "",
    this.currentQuestion = 0,
    this.score = 0,
    this.winner,
    this.error,
    this.success,
    this.message,
    this.lives,
    this.opponent,
  });

  DuelsState copyWith({
    bool? isLoading,
    String? duelId,
    DuelsStatus? status,
    List<dynamic>? tasks,
    String? answer,
    int? currentQuestion,
    int? score,
    String? winner,
    String? error,
    bool? success,
    String? message,
    int? lives,
    String? opponent,
  }) {
    return DuelsState(
      isLoading: isLoading ?? this.isLoading,
      duelId: duelId ?? this.duelId,
      answer: answer ?? this.answer,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      score: score ?? this.score,
      winner: winner ?? this.winner,
      error: error ?? this.error,
      success: success ?? this.success,
      message: message ?? this.message,
      lives: lives ?? this.lives,
      opponent: opponent ?? this.opponent,
    );
  }

  @override
  List<Object?> get props => [
    isLoading, duelId, status, tasks,
    currentQuestion, answer, score,
    winner, error, success, message, lives, opponent,
  ];
}