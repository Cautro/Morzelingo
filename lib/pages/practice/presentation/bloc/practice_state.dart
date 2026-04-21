part of "practice_bloc.dart";


enum PracticeStatus {
  idle,
  active,
  completed,
  error,
  leave,
}

class PracticeState extends Equatable {
  final String? id;
  final bool isLast;
  final String question;
  final String answer;
  final PracticeType? type;
  final int index;
  final bool isLoading;
  final bool? success;
  final String? message;
  final bool isLetter;
  final List<Question>? tasks;
  final PracticeStatus status;

  const PracticeState({
    this.success,
    this.isLast = false,
    this.question = "",
    this.answer = "",
    this.type,
    this.index = 0,
    this.isLoading = false,
    this.message,
    this.isLetter = false,
    this.tasks,
    this.status = PracticeStatus.idle,
    this.id,
  });

  PracticeState copyWith({
    String? id,
    bool? isLoading,
    String? question,
    String? answer,
    PracticeType? type,
    int? index,
    bool? success,
    bool? isLast,
    String? message,
    bool? isLetter,
    List<Question>? tasks,
    PracticeStatus? status,
  }) {
    return PracticeState(
      id: id ?? this.id,
      answer: answer ?? this.answer,
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      question: question ?? this.question,
      isLast: isLast ?? this.isLast,
      index: index ?? this.index,
      type: type ?? this.type,
      isLetter: isLetter ?? this.isLetter,
      tasks: tasks ?? this.tasks,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [answer, message, isLoading, success,
  question, isLast, index, type, isLetter, tasks, status, id];
}

