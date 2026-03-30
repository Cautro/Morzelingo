import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:morzelingo/config.dart';
import 'package:morzelingo/storage_context.dart';

import '../../../main.dart';

class DuelsRepository {

  bool isSuccessStatus(int code) {
    return code >= 200 && code < 300;
  }

  Future<Map<String, String>> _headers() async {
    final token = await StorageService.getItem('token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> createDuel() async {
    final res = await http.post(Uri.parse("${API}/api/duel/matchmake"),
      headers: await _headers(),
      body: jsonEncode({}),
    );
    final _json = jsonDecode(res.body);
    print('${_json}');
    print('${_json}');
    if (!isSuccessStatus(res.statusCode)) {
      throw Exception('Ошибка сервера: ${res.statusCode}');
    }
    return _json;
  }

  Future<Map<String, dynamic>> getStatus(String duelId) async {
    final res = await http.get(
      Uri.parse('$API/api/duels/status/$duelId'),
      headers: await _headers(),
    );
    print('${res.body}');
    if (!isSuccessStatus(res.statusCode)) {
      throw Except('Ошибка сервера: ${res.statusCode}');
    }
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getTasks(String duelId, String lang) async {
    final res = await http.post(
      Uri.parse('$API/api/duels/get-tasks/$duelId?lang=$lang'),
      headers: await _headers(),
    );
    print('${res.body}');
    if (!isSuccessStatus(res.statusCode)) {
      throw Except('Ошибка сервера: ${res.statusCode}');
    }
    return jsonDecode(res.body);
  }

  Future<http.Response> updateScore(String duelId, int score) async {
    final res = await http.post(
    Uri.parse('$API/api/duels/update-score/$duelId'),
      headers: await _headers(),
      body: jsonEncode({'score': score}),
    );
    print('${res.body}');
    if (!isSuccessStatus(res.statusCode)) {
      throw Except('Ошибка сервера: ${res.statusCode}');
    }
    return res;
  }

  Future<Map<String, dynamic>> completeDuel(String duelId) async {
    final res = await http.post(
      Uri.parse('$API/api/duels/complete/$duelId'),
      headers: await _headers(),
    );
    print('complete   ${res.body}');
    if (!isSuccessStatus(res.statusCode)) {
      throw Except('Ошибка сервера: ${res.statusCode}');
    }
    return jsonDecode(res.body);
  }

  Future<Map> leaveDuel(String duelId) async {
    final res = await http.post(
      Uri.parse('$API/api/duels/leave/$duelId'),
      headers: await _headers(),
    );
    print('${res.body}');
    if (!isSuccessStatus(res.statusCode)) {
      throw Except('Ошибка сервера: ${res.statusCode}');
    }
    return jsonDecode(res.body);
  }
}