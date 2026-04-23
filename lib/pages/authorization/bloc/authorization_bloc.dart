import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/core/logger/logger.dart';
import 'package:morzelingo/pages/authorization/repository/authorization_repository.dart';
import 'package:morzelingo/pages/authorization/service/authorization_service.dart';
part 'authorization_event.dart';
part 'authorization_state.dart';

class AuthorizationBloc extends Bloc<AuthorizationEvent, AuthorizationState>{
  final AuthorizationRepository _repository;
  final AuthorizationService _service;
  AuthorizationBloc({
    required AuthorizationRepository repository,
    required AuthorizationService service,
  }) : _repository = repository, _service = service, super(const AuthorizationState()) {

    // Вход
    on<LoginEvent>((event, emit) async {
      AppLogger.d('datas: ${event.login} ${event.password}');
      try {
        final Map<String, dynamic> loginData = await _repository.LoginHandler(event.login, event.password);
        emit(state.copyWith(status: AuthorizationStatus.success, message: loginData["message"]));
      } catch (e) {
        emit(state.copyWith(status: AuthorizationStatus.error, message: e.toString()));
        emit(state.copyWith(status: AuthorizationStatus.idle, message: null));
      }
    });

    // Регистрация
    on<RegisterEvent>((event, emit) async {
      try {
        await _service.checkRegister(event.login, event.password, event.confirmpassword, event.email);
        final Map<String, dynamic> registerData = await _repository.RegisterHandler(event.login, event.password, event.email, event.code);
        emit(state.copyWith(status: AuthorizationStatus.success, message: registerData["message"]));
      } catch (e) {
        emit(state.copyWith(status: AuthorizationStatus.error, message: e.toString()));
        emit(state.copyWith(status: AuthorizationStatus.idle, message: null));
      }
    });

    // Смена регистрации или входа
    on<ChangeModeEvent>((event, emit) {
      if (state.mode == AuthorizationMode.login) {
        emit(state.copyWith(mode: AuthorizationMode.register));
      } else {
        emit(state.copyWith(mode: AuthorizationMode.login));
      }
    });

    // Проверка входа
    on<CheckLoginedEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final bool checkData = await _repository.checkLogined();
        if (checkData) {
          emit(state.copyWith(status: AuthorizationStatus.sessionSuccess, message: "Вход успешен"));
        }
      } catch (e) {
        emit(state.copyWith(status: AuthorizationStatus.idle,));
      } finally {
        emit(state.copyWith(isLoading: false));
      }
    });
  }
}