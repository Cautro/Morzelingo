import 'dart:convert';

import 'package:morzelingo/config.dart';

import '../../storage_context.dart';
import 'package:http/http.dart' as http;


class ApiClient {

  bool checkStatus(int code) {
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

  Future get({required bool jwt, required String endpoint}) async {
    final http.Response res = await http.get(Uri.parse("${API}${endpoint}"),
      headers: jwt ? await _headers(Token: true) : await _headers(Token: false)
    );
    return jsonDecode(res.body);
  }

  Future post({required bool jwt, required String endpoint, Map<String, dynamic>? body}) async {
    final http.Response res = await http.post(Uri.parse("${API}${endpoint}"),
        headers: jwt ? await _headers(Token: true) : await _headers(Token: false),
        body: jsonEncode(body ?? {})
    );
    return jsonDecode(res.body);
  }

}