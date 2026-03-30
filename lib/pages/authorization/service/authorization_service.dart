class AuthorizationService {

  Future<bool> checkRegister(String login, String password, String repeatPassword, String email) async {
    if (repeatPassword != password) {
      throw Exception("Пароли не совпадают");
    }
    if (login.length < 6) {
      throw Exception("Имя пользователя слишком короткое");
    }
    if (!email.contains('@')) {
      throw Exception("Введите валидный email");
    }
    return true;
  }
}