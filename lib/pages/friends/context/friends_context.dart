

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config.dart';
import '../../../storage_context.dart';

class FriendsContext {

  Future<List> getData() async {
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("${API}/api/friends"),
        headers: {
          "Authorization": "Bearer $token"
        });
    final data = await jsonDecode(res.body);
    List _friends = data["friends"];
    print(_friends);

    return _friends;
  }

  Future<Map> addHandler(code) async {
    bool success;
    String message;
    String? token = await StorageService.getItem("token");
    final res = await http.post(Uri.parse("${API}/api/add-to-friend"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"referral_code": code}),
    );
    final data = jsonDecode(res.body);
    print(data);
    if (res.statusCode == 200) {
      message = "Друг добавлен";
      success = true;
    } else {
      message = "${data["message"]}";
      success = false;
    }
    return {"message": message, "success": success};
  }

  Future<Map> deleteHandler(username) async {
    print('${username}');
    String message;
    bool success;
    String? token = await StorageService.getItem("token");
    final res = await http.post(Uri.parse("${API}/api/delete-friend"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"username": username}),
    );
    final data = jsonDecode(res.body);
    print(data);
    if (res.statusCode == 200) {
      message = "Друг удалён";
      success = true;
    } else {
      message = "${data["message"]}";
      success = false;
    }
    print(data);
    return {"message": message, "success": success};
  }
}