import 'dart:convert';

import 'package:morzelingo/config.dart';
import 'package:morzelingo/core/api/response_model.dart';

import '../../storage_context.dart';
import 'package:http/http.dart' as http;


class ApiClient {

  bool checkResponseStatus(int code) {
    return code >= 200 && code < 300;
  }

  Future<Map<String, String>> _headers({required bool Token}) async {
    if(Token) {
      final token = await StorageService.getItem('token');
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
    final http.Response res = await http.get(Uri.parse("${API}${endpoint}"),
      headers: jwt ? await _headers(Token: true) : await _headers(Token: false)
    );
    return ResponseModel(statusCode: res.statusCode, json: jsonDecode(res.body));
  }

  Future<ResponseModel> post({required bool jwt, required String endpoint, Map<String, dynamic>? body}) async {
    final http.Response res = await http.post(Uri.parse("${API}${endpoint}"),
        headers: jwt ? await _headers(Token: true) : await _headers(Token: false),
        body: jsonEncode(body ?? {})
    );
    return ResponseModel(statusCode: res.statusCode, json: jsonDecode(res.body));
  }

}