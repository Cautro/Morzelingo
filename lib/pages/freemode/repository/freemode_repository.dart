import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config.dart';
import '../../../settings_context.dart';
import '../../../storage_context.dart';

class FreemodeRepository {

  Future<Map<String, String>> headers() async {
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
    final res = await http.get(Uri.parse("${API}/api/freemode?"
        "mode=${mode}&lang=${lang}&count=1"),
      headers: await headers(),
    );
    final data = jsonDecode(res.body);
    print(data);
    if (res.statusCode == 200) {
      question = data["questions"][0]["question"];
      answer = data["questions"][0]["answer"];
      print(question);
    } else {
      throw Exception("Произошла ошибка сервера");
    }
    return {"question": question, "answer": answer,};
  }

  Future<void> checkerPractice(bool correct) async {
    final res = await http.post(
      Uri.parse("${API}/api/checker-practice"),
      headers: await headers(),
      body: jsonEncode(
        {"correct": correct},
      ),
    );
  }

  Future<void> completeFreemode() async {
    final res = await http.post(Uri.parse("${API}/api/freemode/complete"),
      headers: await headers(),
    );
  }

}