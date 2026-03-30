part of "authorization_bloc.dart";

class AuthorizationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthorizationEvent {
  LoginEvent({required this.login, required this.password});
  final String login;
  final String password;

  @override
  List<Object?> get props => [login, password];
}

class RegisterEvent extends AuthorizationEvent {
  RegisterEvent({required this.login, required this.password, required this.confirmpassword, required this.code, required this.email});
  final String login;
  final String password;
  final String confirmpassword;
  final String code;
  final String email;

  @override
  List<Object?> get props => [login, password, email, confirmpassword, code];
}

class ChangeModeEvent extends AuthorizationEvent {
  @override
  List<Object?> get props => [];
}

class CheckLoginedEvent extends AuthorizationEvent {
  @override
  List<Object?> get props => [];
}