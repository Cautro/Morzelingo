import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:morzelingo/config.dart';
import 'package:morzelingo/storage_context.dart';

class DuelsRepository {
  Future<Map> createDuel() async {
    String? token = await StorageService.getItem("token");
    final res = await http.post(Uri.parse("${API}/api/duel/matchmake"),
      headers: {
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({}),
    );
    final _json = jsonDecode(res.body);
    print('${_json}');
    print('${_json}');
    return _json;
  }

  Future<Map> getStatus(String duelId) async {
    String? token = await StorageService.getItem("token");
    final res = await http.get(
      Uri.parse('$API/api/duels/status/$duelId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print('${res.body}');
    return jsonDecode(res.body);
  }

  Future<Map> getTasks(String duelId, String lang) async {
    String? token = await StorageService.getItem("token");
    final res = await http.post(
      Uri.parse('$API/api/duels/get-tasks/$duelId?lang=$lang'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print('${res.body}');
    return jsonDecode(res.body);
  }

  Future<http.Response> updateScore(String duelId, int score) async {
    String? token = await StorageService.getItem("token");
    final res = await http.post(
    Uri.parse('$API/api/duels/update-score/$duelId'),
    headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    },
    body: jsonEncode({'score': score}),
    );
    print('${res.body}');
    return res;
  }

  Future<Map> completeDuel(String duelId) async {
    String? token = await StorageService.getItem("token");
    final res = await http.post(
      Uri.parse('$API/api/duels/complete/$duelId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print('complete   ${res.body}');
    return jsonDecode(res.body);
  }

  Future<Map> leaveDuel(String duelId) async {
    String? token = await StorageService.getItem("token");
    final res = await http.post(
      Uri.parse('$API/api/duels/leave/$duelId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print('${res.body}');
    return jsonDecode(res.body);
  }
}