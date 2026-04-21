import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/core/api/response_model.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/logger/logger.dart';
import '../../../settings_context.dart';
import '../../../storage_context.dart';
import '../service/practice_service.dart';

class PracticeRepository {
  final ApiClient _client;
  PracticeRepository(this._client);

  Future<void> completeLesson(String id) async {
    String? token = await StorageService.getItem("token");
    AppLogger.d('token: $token, id: $id');
    final ResponseModel res = await _client.post(jwt: true, endpoint: "/api/complete-lesson", body: {
      "lesson_id": int.tryParse(id) ?? 0
    });
    var json = res.json;
    AppLogger.d(json);
    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except("Ошибка сервера");
    }
  }

  Future<List> getPracticeQuestion(String id) async {
    final lang = await SettingsService.getLang();
    final ResponseModel res = await _client.get(jwt: true, endpoint: "/api/practice/$id?lang=${lang.trim()}");
    var json = res.json;
    var data = json;

    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except("Ошибка сервера");
    }

    return data["questions"];
  }

  Future<void> sendStats(List<SymbolUpdate> updates) async {
    AppLogger.d('${updates.map((e) => e.toJson()).toList()}');
    final ResponseModel res = await _client.post(jwt: true, endpoint: "/api/practice/submit", body: updates.map((e) => e.toJson()).toList(),);

    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except("Ошибка сервера");
    }
  }

  Future<List> getLetterQuestion() async {
    var letter = await StorageService.getItem("letter");
    String? lang = await SettingsService.getLang();
    String encodedLetter = Uri.encodeQueryComponent(letter!);
    final ResponseModel res = await _client.post(jwt: true, endpoint: "/api/practice?letters=$encodedLetter&lang=$lang");
    final Map<String, dynamic> data = res.json;

    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except("Ошибка сервера");
    }

    return data["questions"];
  }

}