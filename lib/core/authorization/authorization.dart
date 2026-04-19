import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';

class Authorization {
  static const _storage = FlutterSecureStorage();

  Future<void> setToken(String token) async {
    await _storage.write(key: "token", value: token);
  }

  Future<String> getToken() async {
    String? token = await _storage.read(key: "token");
    if (token == null) {
      throw Except("Токен авторизации не сохранён");
    }
    return token;
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: "token");
  }
}