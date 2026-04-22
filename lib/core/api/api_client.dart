import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:morzelingo/config.dart';
import 'package:morzelingo/core/api/response_model.dart';
import 'package:morzelingo/core/authorization/authorization.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/core/exceptions/exceptions.dart';


class ApiClient {
  static const Duration _timeout = Duration(seconds: 15);

  bool checkResponseStatus(int code) {
    return code >= 200 && code < 300;
  }

  Future<Map<String, String>> _headers({required bool token}) async {
    if(token) {
      final token = await Authorization().getToken();
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    } else {
      return {
        'Content-Type': 'application/json',
      };
    }
  }

  Future<ResponseModel> get({required bool jwt, required String endpoint}) async {
    try {
      final http.Response res = await http.get(Uri.parse("${AppConfig.apiBaseUrl}$endpoint"),
        headers: jwt ? await _headers(token: true) : await _headers(token: false)
      ).timeout(_timeout);

      if (res.statusCode == 401) {
        throw const UnauthorizedException("Сессия истекла");
      }

      return ResponseModel(statusCode: res.statusCode, json: jsonDecode(res.body));
    } on SocketException {
      throw const NetworkException('Нет подключения к интернету');
    } on TimeoutException {
      throw const TimeoutAppException('Превышено время ожидания запроса');
    } on FormatException {
      throw const InvalidData('Сервер вернул некорректный JSON');
    }  catch (e) {
      if (e is UnknownException) rethrow;

      throw UnknownException('Неизвестная ошибка: $e');
    }
  }

  Future<ResponseModel> post({required bool jwt, required String endpoint, dynamic body}) async {
    try {
      final http.Response res = await http.post(Uri.parse("${AppConfig.apiBaseUrl}$endpoint"),
          headers: jwt ? await _headers(token: true) : await _headers(token: false),
          body: jsonEncode(body ?? {})
      ).timeout(_timeout);

      if (res.statusCode == 401) {
        Authorization().deleteToken();
        throw const UnauthorizedException("Сессия истекла");
      }


      return ResponseModel(statusCode: res.statusCode, json: jsonDecode(res.body));
    } on SocketException {
      throw const NetworkException('Нет подключения к интернету');
    } on TimeoutException {
      throw const TimeoutAppException('Превышено время ожидания запроса');
    } on FormatException {
      throw const InvalidData('Сервер вернул некорректный JSON');
    } catch (e) {
      if (e is UnknownException) rethrow;

      throw UnknownException(
        "Неизвестная ошибка: $e"
      );
    }
  }

}
