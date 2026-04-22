
import 'package:morzelingo/core/exceptions/exceptions.dart';

class AuthorizationService {

  Future<bool> checkRegister(String login, String password, String repeatPassword, String email) async {
    if (login.isEmpty || password.isEmpty || repeatPassword.isEmpty || email.isEmpty) {
      throw ValidationException("Пожалуйста заполните все поля");
    }
    if (repeatPassword != password) {
      throw ValidationException("Пароли не совпадают");
    }
    if (login.length < 4) {
      throw ValidationException("Имя пользователя слишком короткое");
    }
    if (!email.contains('@')) {
      throw ValidationException("Введите валидный email");
    }
    return true;
  }
}