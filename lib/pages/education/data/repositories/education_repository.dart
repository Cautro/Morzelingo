import 'package:morzelingo/core/api/api_client.dart';
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
    final Map<String, dynamic> profileJson = await _client.get(jwt: true, endpoint: "/api/profile");
    print("profile ${profileJson}");
    final id = profileJson["lesson_done_${lang.trim()}"] + 1;
    final Map<String, dynamic> json = await _client.get(jwt: true, endpoint: "/api/lessons/$id/?lang=${lang.trim()}");
    print("data ${json}");
    print("title: ${LessonModel.fromJson(json).toEnity().title}");

    return LessonModel.fromJson(json).toEnity();
  }

  @override
  Future<List<dynamic>> getCompletedLessons() async {
    final String lang = await SettingsService.getLang();
    final Map<String, dynamic> profileJson = await _client.get(jwt: true, endpoint: "/api/profile");
    print("profile ${profileJson}");
    final lessonsDone = profileJson["lesson_done_${lang.trim()}"] + 1;
    final List json = await _client.get(jwt: true, endpoint: "/api/lessons/");
    print("data ${json}");

    return json.take(int.parse(lessonsDone)).toList();
  }
}