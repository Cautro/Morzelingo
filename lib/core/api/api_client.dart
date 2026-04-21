import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:morzelingo/config.dart';
import 'package:morzelingo/core/api/response_model.dart';
import 'package:morzelingo/core/authorization/authorization.dart';
import 'package:http/http.dart' as http;


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
      final http.Response res = await http.get(Uri.parse("$API$endpoint"),
        headers: jwt ? await _headers(token: true) : await _headers(token: false)
      ).timeout(_timeout);
      return ResponseModel(statusCode: res.statusCode, json: jsonDecode(res.body));
    } on SocketException {
      throw const ApiClientException(
        type: ApiErrorType.noInternet,
        message: 'Нет подключения к интернету',
      );
    } on TimeoutException {
      throw const ApiClientException(
        type: ApiErrorType.timeout,
        message: 'Превышено время ожидания запроса',
      );
    } on FormatException {
      throw const ApiClientException(
        type: ApiErrorType.invalidJson,
        message: 'Сервер вернул некорректный JSON',
      );
    }  catch (e) {
      if (e is ApiClientException) rethrow;

      throw ApiClientException(
        type: ApiErrorType.unknown,
        message: 'Неизвестная ошибка: $e',
      );
    }
  }

  Future<ResponseModel> post({required bool jwt, required String endpoint, dynamic body}) async {
    try {
      final http.Response res = await http.post(Uri.parse("$API$endpoint"),
          headers: jwt ? await _headers(token: true) : await _headers(token: false),
          body: jsonEncode(body ?? {})
      ).timeout(_timeout);
      return ResponseModel(statusCode: res.statusCode, json: jsonDecode(res.body));
    } on SocketException {
      throw const ApiClientException(
        type: ApiErrorType.noInternet,
        message: 'Нет подключения к интернету',
      );
    } on TimeoutException {
      throw const ApiClientException(
        type: ApiErrorType.timeout,
        message: 'Превышено время ожидания запроса',
      );
    } on FormatException {
      throw const ApiClientException(
        type: ApiErrorType.invalidJson,
        message: 'Сервер вернул некорректный JSON',
      );
    } catch (e) {
      if (e is ApiClientException) rethrow;

      throw ApiClientException(
        type: ApiErrorType.unknown,
        message: 'Неизвестная ошибка: $e',
      );
    }
  }

}

enum ApiErrorType {
  noInternet,
  timeout,
  invalidJson,
  unauthorized,
  forbidden,
  notFound,
  server,
  unknown,
}

class ApiClientException implements Exception {
  final ApiErrorType type;
  final String message;

  const ApiClientException({
    required this.type,
    required this.message,
  });

  @override
  String toString() => 'ApiClientException(type: $type, message: $message)';
}