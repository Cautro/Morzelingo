part of 'authorization_bloc.dart';

enum AuthorizationStatus {
  idle,
  success,
  error,
}
enum AuthorizationMode {
  login,
  register,
}

class AuthorizationState extends Equatable {
  final AuthorizationStatus status;
  final String? message;
  final AuthorizationMode mode;

  const AuthorizationState({
    this.status = AuthorizationStatus.idle,
    this.message,
    this.mode = AuthorizationMode.login
  });

  AuthorizationState copyWith({
    AuthorizationStatus? status,
    String? message,
    AuthorizationMode? mode
  }) {
    return AuthorizationState(
      status: status ?? this.status,
      message: message ?? this.message,
      mode: mode ?? this.mode
    );
  }

  @override
  List<Object?> get props => [status, message, mode];
}


