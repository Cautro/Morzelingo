import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/core/api/response_model.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/logger/logger.dart';
import '../../../storage_context.dart';

class AuthorizationRepository {
  final ApiClient _client;
  const AuthorizationRepository(this._client);

  Future<Map<String, dynamic>> LoginHandler(String login, String password) async {
    final ResponseModel res = await _client.post(jwt: false, endpoint: "/api/login", body: {"username": login, "password": password});
    final json = res.json;
    AppLogger.d('$json');
    if (_client.checkResponseStatus(res.statusCode)) {
      await StorageService.setItem("token", json["token"]);
      return {"success": true, "message": "Вход успешен"};
    } else {
      throw Except(json["error"].toString());
    }
  }

  Future<Map<String, dynamic>> RegisterHandler(String login, String password, String email, String code) async {
    final ResponseModel res = await _client.post(jwt: false, endpoint: "/api/register", body: {
      "username": login,
      "email": email,
      "password": password,
      "referral_code": code,
    });
    final json = res.json;
    AppLogger.d('$json');
    if (_client.checkResponseStatus(res.statusCode)) {
      await StorageService.setItem("token", json["token"]);
      return {"success": true, "message": "Регистрация успешна"};
    } else {
      throw Except(json["error"].toString());
    }
  }

  Future<bool> checkLogined() async {
    final ResponseModel res = await _client.get(jwt: true, endpoint: "/api/profile");
    final data = res.json;
    AppLogger.d(data);
    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except("Ваши данные для авторизации недействительны");
    }
    return true;
  }
}