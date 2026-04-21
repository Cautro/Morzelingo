import 'dart:convert';

import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/core/api/response_model.dart';
import 'package:morzelingo/pages/freemode/models/question_model.dart';
import 'package:morzelingo/pages/practice/data/models/question_model.dart';
import 'package:morzelingo/pages/practice/domain/entities/question.dart';
import 'package:morzelingo/pages/practice/domain/repositories/practice_repository_interface.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/logger/logger.dart';
import '../../../../settings_context.dart';
import '../../../../storage_context.dart';
import '../../domain/services/practice_service.dart';

class PracticeRepository extends IPracticeRepository {
  final ApiClient _client;
  PracticeRepository(this._client);

  @override
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

  @override
  Future<List<Question>> getPracticeQuestion(String id) async {
    final lang = await SettingsService.getLang();
    final ResponseModel res = await _client.get(jwt: true, endpoint: "/api/practice/$id?lang=${lang.trim()}");
    final Map<String, dynamic> json = res.json is String
        ? jsonDecode(res.json as String) as Map<String, dynamic>
        : res.json as Map<String, dynamic>;

    final List<Question> data = (json["questions"] as List<dynamic>)
        .map<Question>((e) => PracticeQuestionModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();

    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except("Ошибка сервера");
    }

    return data;
  }

  @override
  Future<void> sendStats(List<SymbolUpdate> updates) async {
    AppLogger.d('${updates.map((e) => e.toJson()).toList()}');
    final ResponseModel res = await _client.post(jwt: true, endpoint: "/api/practice/submit", body: updates.map((e) => e.toJson()).toList(),);

    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except("Ошибка сервера");
    }
  }

  @override
  Future<List<Question>> getLetterQuestion() async {
    var letter = await StorageService.getItem("letter");
    String? lang = await SettingsService.getLang();
    String encodedLetter = Uri.encodeQueryComponent(letter!);
    final ResponseModel res = await _client.post(jwt: true, endpoint: "/api/practice?letters=$encodedLetter&lang=$lang");

    if (!_client.checkResponseStatus(res.statusCode)) {
      throw Except("Ошибка сервера");
    }

    final Map<String, dynamic> json = res.json is String
        ? jsonDecode(res.json as String) as Map<String, dynamic>
        : res.json as Map<String, dynamic>;

    final List<Question> data = (json["questions"] as List<dynamic>)
        .map<Question>((e) => PracticeQuestionModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();

    return data;
  }

}