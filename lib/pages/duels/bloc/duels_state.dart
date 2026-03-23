part of 'duels_bloc.dart';

class DuelsState {
  final bool isLoading;
  final String? duelId;
  final String status;
  // idle | waiting | active | playing | submitting | waitingResult | finished | error
  final List<dynamic> tasks;
  final int currentQuestion;
  final String answer;
  final int score;
  final String? winner;
  final String? error;
  final bool? success;
  final String? message;

  const DuelsState({
    this.isLoading = false,
    this.duelId,
    this.status = "idle",
    this.tasks = const [],
    this.answer = "",
    this.currentQuestion = 0,
    this.score = 0,
    this.winner,
    this.error,
    this.success,
    this.message
  });

  DuelsState copyWith({
    bool? isLoading,
    String? duelId,
    String? status,
    List<dynamic>? tasks,
    String? answer,
    int? currentQuestion,
    int? score,
    String? winner,
    String? error,
    bool? success,
    String? message,
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
    );
  }
}


class DuelsInitial extends DuelsState {}
