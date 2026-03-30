

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config.dart';
import '../../../settings_context.dart';
import '../../../storage_context.dart';

class EducationContext {

  Future<Map> getEducationData() async {
    String? token = await StorageService.getItem("token");
    print(token);
    final res = await http.get(Uri.parse("$API/api/profile"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = await jsonDecode(res.body);
    final lang = await SettingsService.getLang();
    int lessondone = int.parse(data["lesson_done_${lang.trim()}"].toString());
    print(data);
    print("done: $lessondone");

    final res1 = await http.get(Uri.parse("$API/api/lessons/${lessondone + 1}?lang=${lang.trim()}"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    var data1 = jsonDecode(res1.body);
      var lessons = data1;
    print(lessons);

    return lessons;
  }

  Future<Map> getLessonData() async {
    String? id = await StorageService.getItem("lessonid");
    String? token = await StorageService.getItem("token");
    final lang = await SettingsService.getLang();
    final res = await http.get(Uri.parse("$API/api/lessons/$id/?lang=${lang.trim()}"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    var data = jsonDecode(res.body);
    var lesson = data;
    print(lesson);

    final res1 = await http.get(Uri.parse("$API/api/profile"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data1 = await jsonDecode(res1.body);
    print(data);
    String lessondone = data1["lesson_done_$lang"].toString();
    print(lessondone);

    bool done = false;

    id = await StorageService.getItem("lessonid");
    print("id $id, done$lessondone");
    if ((int.parse(lessondone)) >= (int.parse(id!))) {
     done = true;
    } else {
     done = false;
    }
    print('$done');

    return {"done": done, "lesson": lesson};

  }

  Future<List> getCompletedLessonsData() async {
    String? lang = await SettingsService.getLang();
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("$API/api/profile"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = await jsonDecode(res.body);
    int lessondone = int.parse(data["lesson_done_$lang"].toString());
    print(data);
    print("done: $lessondone");

    final res1 = await http.get(Uri.parse("$API/api/lessons"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    var data1 = jsonDecode(res1.body);
      var lessons = data1;
      var completed = lessons.take(lessondone).toList();
      return completed;
  }
}