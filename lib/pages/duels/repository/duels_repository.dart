import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:morzelingo/config.dart';
import 'package:morzelingo/storage_context.dart';

class DuelsRepository {
  Future<Map> createDuel() async {
    String? token = await StorageService.getItem("token");
    final res = await http.post(Uri.parse("${API}/api/duel/create"),
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

  Future<Map> joinDuel() async {
    String? token = await StorageService.getItem("token");
    final res = await http.post(
      Uri.parse('$API/api/duel/join'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print('${res.body}');
    return {
      'statusCode': res.statusCode,
      'body': jsonDecode(res.body),
    };
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

  Future<http.Response> submitScore(String duelId, int score) async {
    String? token = await StorageService.getItem("token");
    final res = await http.post(
    Uri.parse('$API/api/duels/get-score/$duelId'),
    headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    },
    body: jsonEncode({'score': score}),
    );
    print('${res.body}');
    return res;
  }

  Future<Map> finishDuel(String duelId) async {
    String? token = await StorageService.getItem("token");
    final res = await http.post(
      Uri.parse('$API/api/duels/finish/$duelId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print('${res.body}');
    return jsonDecode(res.body);
  }
}