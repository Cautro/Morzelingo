import 'dart:convert';
import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/core/api/response_model.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import '../../../core/logger/logger.dart';

class FriendsRepository {
  final ApiClient _client;
  FriendsRepository(this._client);

  Future<List> getData() async {
    final ResponseModel res = await _client.get(jwt: true, endpoint: "/api/friends");
    final data = res.json;
    List friends = data["friends"];
    AppLogger.d(friends);

    return friends;
  }

  Future<String> addHandler(String code) async {
    AppLogger.d(code);
    final ResponseModel res = await _client.post(jwt: true, endpoint: "/api/friends/add", body: {"friend": code});
    final data = res.json;
    AppLogger.d(data);
    if (!_client.checkResponseStatus(res.statusCode)) {
      throw ServerException(data["message"]);
    }
    return "Друг добавлен";
  }

  Future<String> deleteHandler(String username) async {
    final ResponseModel res = await _client.post(jwt: true, endpoint: "/api/friends/delete", body: {"friend": username});
    final data = res.json;
    AppLogger.d(data);
    if (!_client.checkResponseStatus(res.statusCode)) {
      throw ServerException(data["message"]);
    }
    AppLogger.d(data);
    return "Друг удалён";
  }

}