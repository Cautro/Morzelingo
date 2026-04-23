part of 'authorization_bloc.dart';

enum AuthorizationStatus {
  idle,
  success,
  error,
  sessionSuccess,
}
enum AuthorizationMode {
  login,
  register,
}

class AuthorizationState extends Equatable {
  final AuthorizationStatus status;
  final String? message;
  final AuthorizationMode mode;
  final bool isLoading;

  const AuthorizationState({
    this.status = AuthorizationStatus.idle,
    this.message,
    this.mode = AuthorizationMode.login,
    this.isLoading = false,
  });

  AuthorizationState copyWith({
    AuthorizationStatus? status,
    String? message,
    AuthorizationMode? mode,
    bool? isLoading
  }) {
    return AuthorizationState(
      status: status ?? this.status,
      message: message ?? this.message,
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading
    );
  }

  @override
  List<Object?> get props => [status, message, mode, isLoading];
}


