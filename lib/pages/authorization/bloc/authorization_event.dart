part of "authorization_bloc.dart";

abstract class AuthorizationEvent extends Equatable {
  const AuthorizationEvent();
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthorizationEvent {
  const LoginEvent({required this.login, required this.password});
  final String login;
  final String password;

  @override
  List<Object?> get props => [login, password];
}

class RegisterEvent extends AuthorizationEvent {
  const RegisterEvent({required this.login, required this.password, required this.confirmpassword, required this.code, required this.email});
  final String login;
  final String password;
  final String confirmpassword;
  final String code;
  final String email;

  @override
  List<Object?> get props => [login, password, email, confirmpassword, code];
}

class ChangeModeEvent extends AuthorizationEvent {
  const ChangeModeEvent();
  @override
  List<Object?> get props => [];
}

class CheckLoginedEvent extends AuthorizationEvent {
  const CheckLoginedEvent();
  @override
  List<Object?> get props => [];
}