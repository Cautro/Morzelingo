import 'dart:convert';
import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/core/api/response_model.dart';
import '../../../config.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../core/logger/logger.dart';
import '../../../settings_context.dart';

class FreemodeRepository {
  final ApiClient _client;
  FreemodeRepository(this._client);

  Future<Map<String, String>> getQuestion(String mode) async {
    String question;
    String answer;
    String? lang = await SettingsService.getLang();
    final ResponseModel res = await _client.get(jwt: true, endpoint: "$API/api/freemode?"
        "mode=$mode&lang=$lang&count=1");
    final data = jsonDecode(res.json);
    AppLogger.d(data);
    if (_client.checkResponseStatus(res.statusCode)) {
      question = data["questions"][0]["question"];
      answer = data["questions"][0]["answer"];
      AppLogger.d(question);
    } else {
      throw Except("Произошла ошибка сервера");
    }
    return {"question": question, "answer": answer,};
  }

  Future<void> completeFreemode() async {
    final ResponseModel res = await _client.post(jwt: true, endpoint: "/api/freemode/complete");
    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except("Произошла ошибка");
    }
  }

}