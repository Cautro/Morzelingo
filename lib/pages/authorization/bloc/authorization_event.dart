part of "authorization_bloc.dart";

class AuthorizationEvent {}

class LoginEvent extends AuthorizationEvent {
  LoginEvent({required this.login, required this.password});
  final String login;
  final String password;
}

class RegisterEvent extends AuthorizationEvent {
  RegisterEvent({required this.login, required this.password, required this.confirmpassword, required this.code, required this.email});
  final String login;
  final String password;
  final String confirmpassword;
  final String code;
  final String email;
}

class CheckLoginedEvent extends AuthorizationEvent {}