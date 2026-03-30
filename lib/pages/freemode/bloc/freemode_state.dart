part of 'freemode_bloc.dart';

enum FreemodeStatus {
  idle,
  error,
  active,
}

enum FreemodeMode {
  text,
  audio,
}

class FreemodeState extends Equatable {

  final bool isLoading;
  final String question;
  final String answer;
  final String? message;
  final bool? success;
  final FreemodeStatus status;
  final FreemodeMode? mode;

  const FreemodeState({
    this.isLoading = false,
    this.question = "",
    this.answer = "",
    this.message,
    this.success,
    this.status = FreemodeStatus.idle,
    this.mode,
  });

  FreemodeState copyWith({
    bool? isLoading,
    String? question,
    String? answer,
    String? message,
    bool? success,
    FreemodeStatus? status,
    FreemodeMode? mode
  }) {
    return FreemodeState(
      message: message ?? this.message,
      success: success ?? this.success,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      answer: answer ?? this.answer,
      question: question ?? this.question,
      mode: mode ?? this.mode
    );
  }


  @override
  List<Object?> get props => [
    isLoading, question, answer, message, success, status, mode
  ];

}

