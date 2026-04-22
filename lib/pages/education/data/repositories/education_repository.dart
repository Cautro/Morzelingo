import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/core/api/response_model.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/core/logger/logger.dart';
import 'package:morzelingo/pages/education/data/models/lesson_model.dart';
import 'package:morzelingo/pages/education/domain/repositories/education_repository_interface.dart';
import 'package:morzelingo/settings_context.dart';
import '../../domain/entities/lesson.dart';

class EducationRepository extends IEducationRepository {
  final ApiClient _client;

  EducationRepository(this._client);

  @override
  Future<Lesson> getLesson() async {
    final String lang = await SettingsService.getLang();

    final ResponseModel profileResponse = await _client.get(
        jwt: true, endpoint: "/api/profile");
    if (!_client.checkResponseStatus(profileResponse.statusCode)) {
      throw ServerException("Ошибка при получении данных с сервера");
    }
    AppLogger.d("profile ${profileResponse.json}");
    final id = profileResponse.json["lesson_done_${lang.trim()}"] + 1;

    final ResponseModel lessonsResponse = await _client.get(
        jwt: true, endpoint: "/api/lessons/$id/?lang=${lang.trim()}");
    if (!_client.checkResponseStatus(lessonsResponse.statusCode)) {
      throw ServerException("Ошибка при получении данных с сервера");
    }
    AppLogger.d("data ${lessonsResponse.json}");
    AppLogger.d("title: ${LessonModel
        .fromJson(lessonsResponse.json)
        .toEntity()
        .title}");

    return LessonModel.fromJson(lessonsResponse.json).toEntity();
  }

  @override
  Future<List<Lesson>> getCompletedLessons() async {
    final String lang = await SettingsService.getLang();

    final ResponseModel profileResponse =
    await _client.get(jwt: true, endpoint: "/api/profile");
    if (!_client.checkResponseStatus(profileResponse.statusCode)) {
      throw ServerException("Ошибка при получении данных с сервера");
    }

    final int lessonsDone = (profileResponse.json["lesson_done_${lang.trim()}"] as num?)?.toInt() ?? 0;

    final ResponseModel lessonsResponse =
    await _client.get(jwt: true, endpoint: "/api/lessons/");
    if (!_client.checkResponseStatus(lessonsResponse.statusCode)) {
      throw ServerException("Ошибка при получении данных с сервера");
    }

    final List<Lesson> lessons = (lessonsResponse.json as List).take(lessonsDone).map((e) => LessonModel.fromJson(e as Map<String, dynamic>).toEntity()).toList();

    if (lessons.isNotEmpty) {
      AppLogger.d(lessons[0].title);
    }

    return lessons;
  }
}