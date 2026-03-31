import '../../../main.dart';

class AuthorizationService {

  Future<bool> checkRegister(String login, String password, String repeatPassword, String email) async {
    if (login.isEmpty || password.isEmpty || repeatPassword.isEmpty || email.isEmpty) {
      throw Except("Пожалуйста заполните все поля");
    }
    if (repeatPassword != password) {
      throw Except("Пароли не совпадают");
    }
    if (login.length < 4) {
      throw Except("Имя пользователя слишком короткое");
    }
    if (!email.contains('@')) {
      throw Except("Введите валидный email");
    }
    return true;
  }
}