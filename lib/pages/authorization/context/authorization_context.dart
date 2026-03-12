import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config.dart';
import '../../../settings_context.dart';
import '../../../storage_context.dart';

class AuthorizationContext {

  Future<Map<dynamic, dynamic>> loginHandler(String login, String password) async {
    bool success;
    String message;
    if (login == "" || password == "") {
        message = "Пожалуйста введите логин и пароль";
        success = false;
      return {"message": message, "success": success};
    }
    final res = await http.post(Uri.parse("${API}/api/login"),
        headers: {"Content-Type": "application/json",},
        body: jsonEncode({
          "username": login,
          "password": password
        })
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await StorageService.setItem("token", data["token"]);
        message = "Вход успешен";
        success = true;
      print(data);
    } else {
      message = data["message"];
      success = false;
      print(res.body);
      SettingsService.setDefault();
    }
    return {"message": message, "success": success};
  }

  Future<bool> checkLogined() async {
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("${API}/api/profile"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = await jsonDecode(res.body);
    print(data);
    if (res.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<Map> registerHandler(String login, String password, String email, String confirmpassword, String code) async {
    bool success;
    String message;
    if (login == "" || password == "" || email == "" || confirmpassword == "") {
      message = "Пожалуйста введите логин, email и пароль";
      success = false;
      return {"success": success, "message": message};
    } else if (password != confirmpassword) {
      message = "Пожалуйста введите одинаковые пароли";
      success = false;
      return {"success": success, "message": message};
    }
    final res = await http.post(Uri.parse("${API}/api/register"),
        headers: {"Content-Type": "application/json",},
        body: jsonEncode({
          "username": login,
          "email": email,
          "password": password,
          "referral_code": code,
        })
    );
    final data = jsonDecode(res.body);
    print("${res.statusCode} ${res.body}");
    print(res.statusCode == 200);
    if (res.statusCode == 200) {
      await StorageService.setItem("token", data["token"]);
      success = true;
      message = "Регистрация успешна";
    } else {
      message = data["message"];
      success = false;
      print(res.body);
      SettingsService.setDefault();
    }
    return {"success": success, "message": message};
  }
}