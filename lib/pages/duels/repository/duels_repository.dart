import 'dart:convert';
import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/core/api/response_model.dart';

import '../../../core/exceptions/exceptions.dart';
import '../../../core/logger/logger.dart';

class DuelsRepository {
  final ApiClient _client;
  DuelsRepository(this._client);

  Future<Map<String, dynamic>> createDuel() async {
    final ResponseModel res = await _client.post(jwt: true, endpoint: "/api/duel/matchmake");
    final json = res.json;
    AppLogger.d('$json');
    AppLogger.d('$json');
    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Exception('Ошибка сервера: ${res.statusCode}');
    }
    return json;
  }

  Future<Map<String, dynamic>> getStatus(String duelId) async {
    final ResponseModel res = await _client.get(jwt: true, endpoint: "/api/duels/status/$duelId");
    AppLogger.d(res.json);
    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except('Ошибка сервера: ${res.statusCode}');
    }
    return res.json;
  }

  Future<Map<String, dynamic>> getTasks(String duelId, String lang) async {
    final ResponseModel res = await _client.post(jwt: true, endpoint: "/api/duels/get-tasks/$duelId?lang=$lang");
    AppLogger.d(res.json);
    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except('Ошибка сервера: ${res.statusCode}');
    }
    return jsonDecode(res.json);
  }

  Future<void> updateScore(String duelId, int score) async {
    final ResponseModel res = await _client.post(jwt: true, endpoint: "/api/duels/update-score/$duelId", body: {"score": score});
    AppLogger.d(res.json);
    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except('Ошибка сервера: ${res.statusCode}');
    }
  }

  Future<Map<String, dynamic>> completeDuel(String duelId) async {
    final ResponseModel res = await _client.post(jwt: true, endpoint: "/api/duels/complete/$duelId");
    AppLogger.d('complete   ${res.json}');
    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except('Ошибка сервера: ${res.statusCode}');
    }
    return res.json;
  }

  Future<Map> leaveDuel(String duelId) async {
    final ResponseModel res = await _client.post(jwt: true, endpoint: "/api/duels/leave/$duelId");
    AppLogger.d(res.json);
    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except('Ошибка сервера: ${res.statusCode}');
    }
    return res.json;
  }
}