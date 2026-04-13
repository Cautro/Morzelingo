import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../settings_context.dart';
import '../../../storage_context.dart';
import '../service/practice_service.dart';

class PracticeRepository {

  bool _isSuccessStatus(int code) {
    return code >= 200 && code < 300;
  }

  Future<Map<String, String>> _headers() async {
    String? token = await StorageService.getItem("token");
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> completeLesson() async {
    String? id = await StorageService.getItem("lessonid");
    String? token = await StorageService.getItem("token");
    print('token: $token, id: $id');
    final res = await http.post(Uri.parse("$API/api/complete-lesson"),
      headers: await _headers(),
      body: jsonEncode({
        "lesson_id": int.parse(id ?? "0")
      }),
    );
    var json = jsonDecode(res.body);
    print(json);
    if (!_isSuccessStatus(res.statusCode)) {
      throw Except("Ошибка сервера");
    }
  }

  Future<List> getPracticeQuestion() async {
    String? id = await StorageService.getItem("lessonid");
    final lang = await SettingsService.getLang();
    final res = await http.get(Uri.parse("$API/api/practice/$id?lang=${lang.trim()}"),
      headers: await _headers(),
    );
    var json = jsonDecode(res.body);
    var data = json;

    if (!_isSuccessStatus(res.statusCode)) {
      throw Except("Ошибка сервера");
    }

    return data["questions"];
  }

  Future<void> sendStats(List<SymbolUpdate> updates) async {
    print('${updates.map((e) => e.toJson()).toList()}');
    final response = await http.post(
      Uri.parse("$API/api/practice/submit"),
      headers: await _headers(),
      body: jsonEncode(
        updates.map((e) => e.toJson()).toList(),
      ),
    );

    if (!_isSuccessStatus(response.statusCode)) {
      throw Except("Ошибка сервера");
    }
  }

  Future<List> getLetterQuestion() async {
    var letter = await StorageService.getItem("letter");
    String? lang = await SettingsService.getLang();
    String encodedLetter = Uri.encodeQueryComponent(letter!);
    final res = await http.post(Uri.parse("$API/api/practice?letters=$encodedLetter&lang=$lang"),
        headers: await _headers(),
        body: jsonEncode({})
    );
    final Map<String, dynamic> data = jsonDecode(res.body);

    if (!_isSuccessStatus(res.statusCode)) {
      throw Except("Ошибка сервера");
    }

    return data["questions"];
  }

}