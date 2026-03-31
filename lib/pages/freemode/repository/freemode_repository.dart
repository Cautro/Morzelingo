import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config.dart';
import '../../../main.dart';
import '../../../settings_context.dart';
import '../../../storage_context.dart';

class FreemodeRepository {

  bool _checkRes(int code) {
    if (code <= 299 && code >= 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<Map<String, String>> _headers() async {
    String? token = await StorageService.getItem("token");
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<Map<String, String>> getQuestion(String mode) async {
    String question;
    String answer;
    String? lang = await SettingsService.getLang();
    final res = await http.get(Uri.parse("$API/api/freemode?"
        "mode=$mode&lang=$lang&count=1"),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    print(data);
    if (_checkRes(res.statusCode)) {
      question = data["questions"][0]["question"];
      answer = data["questions"][0]["answer"];
      print(question);
    } else {
      throw Except("Произошла ошибка сервера");
    }
    return {"question": question, "answer": answer,};
  }

  Future<void> completeFreemode() async {
    final res = await http.post(Uri.parse("$API/api/freemode/complete"),
      headers: await _headers(),
    );
    if (!_checkRes(res.statusCode)) {
      throw Except("Произошла ошибка");
    }
  }

}