import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:morzelingo/config.dart';
import 'package:morzelingo/storage_context.dart';

class DuelsRepository {

  Future<Map<String, String>> _headers() async {
    final token = await StorageService.getItem('token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map> createDuel() async {
    final res = await http.post(Uri.parse("${API}/api/duel/matchmake"),
      headers: await _headers(),
      body: jsonEncode({}),
    );
    final _json = jsonDecode(res.body);
    print('${_json}');
    print('${_json}');
    return _json;
  }

  Future<Map> getStatus(String duelId) async {
    final res = await http.get(
      Uri.parse('$API/api/duels/status/$duelId'),
      headers: await _headers(),
    );
    print('${res.body}');
    return jsonDecode(res.body);
  }

  Future<Map> getTasks(String duelId, String lang) async {
    final res = await http.post(
      Uri.parse('$API/api/duels/get-tasks/$duelId?lang=$lang'),
      headers: await _headers(),
    );
    print('${res.body}');
    return jsonDecode(res.body);
  }

  Future<http.Response> updateScore(String duelId, int score) async {
    final res = await http.post(
    Uri.parse('$API/api/duels/update-score/$duelId'),
      headers: await _headers(),
      body: jsonEncode({'score': score}),
    );
    print('${res.body}');
    return res;
  }

  Future<Map> completeDuel(String duelId) async {
    final res = await http.post(
      Uri.parse('$API/api/duels/complete/$duelId'),
      headers: await _headers(),
    );
    print('complete   ${res.body}');
    return jsonDecode(res.body);
  }

  Future<Map> leaveDuel(String duelId) async {
    final res = await http.post(
      Uri.parse('$API/api/duels/leave/$duelId'),
      headers: await _headers(),
    );
    print('${res.body}');
    return jsonDecode(res.body);
  }
}