part of 'authorization_bloc.dart';

class AuthorizationState {}

class AuthorizationInitial extends AuthorizationState {}

class LoginState extends AuthorizationState {
  LoginState({required this.success, required this.message});
  final bool success;
  final String message;
}

class RegisterState extends AuthorizationState {
  RegisterState({required this.success, required this.message});
  final bool success;
  final String message;
}

class CheckLoginedState extends AuthorizationState {
  CheckLoginedState({required this.success});
  final bool success;
}