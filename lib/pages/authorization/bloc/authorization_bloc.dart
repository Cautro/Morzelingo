import 'package:flutter_bloc/flutter_bloc.dart';
import '../context/authorization_context.dart';
part 'authorization_event.dart';
part 'authorization_state.dart';

class AuthorizationBloc extends Bloc<AuthorizationEvent, AuthorizationState>{
  AuthorizationBloc() : super(AuthorizationInitial()) {
    on<LoginEvent>((event, emit) async {
      final _data = await AuthorizationContext().loginHandler(event.login, event.password);
      print('${_data}');
      emit(LoginState(success: _data["success"], message: _data["message"]));
    });
    on<RegisterEvent>((event, emit) async {
      final _data = await AuthorizationContext().registerHandler(event.login, event.password, event.email, event.confirmpassword, event.code);
      print('${_data}');
      emit(RegisterState(success: _data["success"], message: _data["message"]));
    });
    on<CheckLoginedEvent>((event, emit) async {
      final _data = await AuthorizationContext().checkLogined();
      print("${_data}");
      emit(CheckLoginedState(success: _data));
    });
  }
}