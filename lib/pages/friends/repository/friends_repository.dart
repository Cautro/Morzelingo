import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:morzelingo/core/exceptions/exceptions.dart';

import '../../../config.dart';
import '../../../storage_context.dart';

class FriendsRepository {

  Future<Map<String, String>> _headers() async {
    final token = await StorageService.getItem('token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  bool _checkRes(int code) {
    if (code <= 299 && code >= 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List> getData() async {
    final res = await http.get(Uri.parse("$API/api/friends"),
        headers: await _headers(),
    );
    final data = await jsonDecode(res.body);
    List friends = data["friends"];
    print(friends);

    return friends;
  }

  Future<String> addHandler(code) async {
    final res = await http.post(Uri.parse("$API/api/add-to-friend"),
      headers: await _headers(),
      body: jsonEncode({"referral_code": code}),
    );
    final data = jsonDecode(res.body);
    print(data);
    if (!_checkRes(res.statusCode)) {
      throw Except(data["message"]);
    }
    return "Друг добавлен";
  }

  Future<String> deleteHandler(username) async {
    final res = await http.post(Uri.parse("$API/api/delete-friend"),
      headers: await _headers(),
      body: jsonEncode({"username": username}),
    );
    final data = jsonDecode(res.body);
    print(data);
    if (!_checkRes(res.statusCode)) {
      throw Except(data["message"]);
    }
    print(data);
    return "Друг удалён";
  }

}