import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config.dart';
import '../../../main.dart';
import '../../../storage_context.dart';

class AuthorizationRepository {

  Map<String, String> _headers() {
    return {"Content-Type": "application/json",};
  }

  bool _checkRes(int code) {
    if (code <= 299 && code >= 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>> LoginHandler(String login, String password) async {
    final res = await http.post(Uri.parse("$API/api/login"),
        headers: _headers(),
        body: jsonEncode({
          "username": login,
          "password": password
        })
    );
    final json = jsonDecode(res.body);
    print('$json');
    if (_checkRes(res.statusCode)) {
      await StorageService.setItem("token", json["token"]);
      return {"success": true, "message": "Вход успешен"};
    } else {
      throw Except(json["error"].toString());
    }
  }

  Future<Map<String, dynamic>> RegisterHandler(String login, String password, String email, String code) async {
    final res = await http.post(Uri.parse("$API/api/register"),
        headers: _headers(),
        body: jsonEncode({
          "username": login,
          "email": email,
          "password": password,
          "referral_code": code,
        })
    );
    final json = jsonDecode(res.body);
    print('$json');
    if (_checkRes(res.statusCode)) {
      await StorageService.setItem("token", json["token"]);
      return {"success": true, "message": "Регистрация успешна"};
    } else {
      throw Except(json["error"].toString());
    }
  }

  Future<bool> checkLogined() async {
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("$API/api/profile"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(res.body);
    print(data);
    if (!_checkRes(res.statusCode)) {
      throw Except("Ваши данные для авторизации недействительны");
    }
    return true;
  }
}