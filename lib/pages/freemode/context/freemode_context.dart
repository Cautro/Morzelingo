import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

import '../../../config.dart';
import '../../../settings_context.dart';
import '../../../storage_context.dart';

class FreemodeContext {

  final AudioPlayer player = AudioPlayer();

  Future<Map<dynamic, dynamic>> getTextQuestion() async {
    String question;
    String answer;
    bool success;
    String? token = await StorageService.getItem("token");
    String? lang = await SettingsService.getLang();
    final res = await http.get(Uri.parse("${API}/api/freemode?"
        "mode=text&lang=${lang}&count=1"),
      headers: {
        'Authorization': 'Bearer $token',
      },);
    final data = jsonDecode(res.body);
    print(data);
    if (res.statusCode == 200) {
      question = data["questions"][0]["question"];
      answer = data["questions"][0]["answer"];
      success = true;
      print(question);
    } else {
      question = '';
      answer = '';
      success = false;
    }
    return {"question": question, "answer": answer, "success": success};
  }

  Future<Map> answerTextHandler(String decoded, String answer) async {
    String message;
    bool success;
    String? token = await StorageService.getItem("token");
    if (decoded.trim() == answer) {
      final resp = await http.post(
        Uri.parse("${API}/api/checker-practice"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(
          {"correct": true},
        ),
      );
      message = "Верно!";
      success = true;
      final res = await http.post(Uri.parse("${API}/api/freemode/complete"),
        headers: {
          'Authorization': 'Bearer $token',
        },);
      print(res.body);
    } else {
      final res = await http.post(
        Uri.parse("${API}/api/checker-practice"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(
          {"correct": false},
        ),
      );
      message = "Неправильно";
      success = false;
    }
    return {"message": message, "success": success};
  }

  Future<Map> getAudioQuestion() async {
    String? token = await StorageService.getItem("token");
    String? lang = await SettingsService.getLang();
    final res = await http.get(Uri.parse("${API}/api/freemode?mode=morse&lang=${lang}&count=1"),
      headers: {
        'Authorization': 'Bearer $token',
      },);
    final data = jsonDecode(res.body);
    print(data);
    String question = data["questions"][0]["question"];
    String answer = data["questions"][0]["answer"];
    bool success = true;
    return {"success": success, "question": question, "answer": answer};
  }

  Future<Map> answerAudioHandler(String text, String answer) async {
    String message;
    bool success;
    String? token = await StorageService.getItem("token");
    if (text.trim().toUpperCase() == answer) {
      final resp = await http.post(
        Uri.parse("${API}/api/checker-practice"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(
          {"correct": true},
        ),
      );
      message = "Верно!";
      success = true;
      final res = await http.post(Uri.parse("${API}/api/freemode/complete"),
        headers: {
          'Authorization': 'Bearer $token',
        },);
      print(res.body);
    } else {
      final res = await http.post(
        Uri.parse("${API}/api/checker-practice"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(
          {"correct": false},
        ),
      );
      message =  "Неправильно";
      success = false;
    }
    return {"success": success, "message": message};
  }

  Future<Map> playMorse(String question) async {
    print('sdffdfs');

    player.stop();

    final wpm = await SettingsService.getWpm();
    final timing = MorseTiming(wpm);

    for (int i = 0; i < question.length; i++) {

      final char = question[i];

      if (char == '.') {
        await player.play(AssetSource('sounds/dot.wav'));
        await Future.delayed(Duration(milliseconds: timing.dot));

      } else if (char == '-') {
        await player.play(AssetSource('sounds/dash.wav'));
        await Future.delayed(Duration(milliseconds: timing.dash));

      } else if (char == ' ') {
        await Future.delayed(Duration(milliseconds: timing.letterPause));
      }

      if (i < question.length - 1 && question[i + 1] != ' ' && char != ' ') {
        await Future.delayed(Duration(milliseconds: timing.symbolPause));
      }
    }


    return {"isplaying": false, "success": true};
  }
}