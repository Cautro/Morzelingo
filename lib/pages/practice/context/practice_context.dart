

import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

import '../../../config.dart';
import '../../../settings_context.dart';
import '../../../storage_context.dart';
import '../view/practice_audio_page.dart';

class PracticeContext {

  Future<Map> getPracticeQuestion() async {
    String? id = await StorageService.getItem("lessonid");
    String? token = await StorageService.getItem("token");
    print('id: ${id}, token ${token}');
    final lang = await SettingsService.getLang();
    final res = await http.get(Uri.parse("${API}/api/practice/${id}?lang=${lang.trim()}"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    var json = jsonDecode(res.body);
    var data = json;
    print(data);

    return {"data": data};
  }

  Future<Map> nextPracticeQuestion(data, index, isLast) async {
      index++;
      var question = data["questions"][index]["question"].toString().trim();
      var answer = data["questions"][index]["answer"].toString().trim();
      var type = data["questions"][index]["type"];
      print('eeeeee${index}, ${data["questions"].length}');
      if (index >= data["questions"].length - 1) {
        isLast = true;
      } else {
        isLast = false;
      }
      print(isLast);
      if (isLast) {

      } else {
        question = data["questions"][index]["question"].toString().trim();
        answer = data["questions"][index]["answer"].toString().trim();
        type = data["questions"][index]["type"];
      }

      return {"question": question, "answer": answer, "type": type, "islast": isLast, "index": index};
  }

  void completeLesson() async {
    String? id = await StorageService.getItem("lessonid");
    String? token = await StorageService.getItem("token");
    print('token: ${token}, id: ${id}');
    final res = await http.post(Uri.parse("${API}/api/complete-lesson"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "lesson_id": int.parse(id ?? "0")
      }),
    );
    var json = jsonDecode(res.body);
    print(json);
  }

  List<SymbolUpdate> calculateStats(
      String correctAnswer,
      String userAnswer,
      ) {
    correctAnswer = correctAnswer.toUpperCase();
    userAnswer = userAnswer.toUpperCase();

    Map<String, SymbolUpdate> stats = {};

    int maxLength = correctAnswer.length > userAnswer.length
        ? correctAnswer.length
        : userAnswer.length;

    for (int i = 0; i < maxLength; i++) {
      String? correctChar =
      i < correctAnswer.length ? correctAnswer[i] : null;
      String? userChar =
      i < userAnswer.length ? userAnswer[i] : null;

      // если буква была в правильном ответе
      if (correctChar != null) {
        stats.putIfAbsent(
          correctChar,
              () => SymbolUpdate(symbol: correctChar),
        );
      }

      if (correctChar != null && userChar == correctChar) {
        stats[correctChar]!.correct++;
      } else {
        // ошибка
        if (correctChar != null) {
          stats[correctChar]!.wrong++;
        }
      }
    }

    return stats.values.toList();
  }

  Future<void> sendStats(List<SymbolUpdate> updates) async {
    String? token = await StorageService.getItem("token");
    final response = await http.post(
      Uri.parse("${API}/api/practice/submit"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(
        updates.map((e) => e.toJson()).toList(),
      ),
    );

    if (response.statusCode != 200) {
      print("Error: ${response.body}");
    }
  }

  void practiceChecker(bool correct) async {
    String? token = await StorageService.getItem("token");
    final res = await http.post(
      Uri.parse("${API}/api/checker-practice"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(
        {"correct": correct},
      ),
    );
  }

  Future<Map> getLetterQuestion(index) async {
    var letter = await StorageService.getItem("letter");
    String? lang = await SettingsService.getLang();
    String? token = await StorageService.getItem("token");
    String encodedLetter = Uri.encodeQueryComponent(letter!);
    final res = await http.post(Uri.parse("${API}/api/practice?letters=${encodedLetter}&lang=${lang}"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({})
    );
    print(res.body);
    var json = jsonDecode(res.body);
    var data = json;
    return data;
  }
  Future<Map> nextLetterQuestion(data, index, isLast) async {
      index++;
      if (index >= data["questions"].length) {
        isLast = true;
      } else {
        isLast = false;
      }
      print(isLast);
      if (isLast) {
      }
    return {"index": index, "islast": isLast};
  }

  final player = AudioPlayer();

  Future<void> playMorseAudio(question) async {
    const int dotDuration = 200;   // миллисекунды для точки
    const int dashDuration = 600;  // тире = 3 точки
    const int symbolPause = 100;   // пауза между символами
    const int letterPause = 600;   // пауза между буквами (3 точки)
    const int wordPause = 1400;    // пауза между словами (7 точек)

    for (int i = 0; i < question.length; i++) {
      final char = question[i];
      if (char == '•') {
        await player.play(AssetSource('sounds/dot.wav'));
        await Future.delayed(Duration(milliseconds: dotDuration));
      } else if (char == '—') {
        await player.play(AssetSource('sounds/dash.wav'));
        await Future.delayed(Duration(milliseconds: dashDuration));
      } else if (char == ' ') {
        // если пробел, это конец буквы или слова
        await Future.delayed(Duration(milliseconds: letterPause));
      }

      // пауза между символами (если это не последний символ и не пробел)
      if (i < question.length - 1 && question[i + 1] != ' ' && char != ' ') {
        await Future.delayed(Duration(milliseconds: symbolPause));
      }
    }
  }
}