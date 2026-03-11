import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/pages/practice_audio_page.dart';
import 'package:morzelingo/pages/practice_morse_page.dart';
import 'package:morzelingo/pages/practice_text_page.dart';

import '../config.dart';
import '../settings_context.dart';
import '../storage_context.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  var data;
  var question;
  var answer;
  var type;
  bool isLast = false;
  int index = 0;

  @override

  void getQuestion() async {
    String? id = await StorageService.getItem("lessonid");
    String? token = await StorageService.getItem("token");
    final lang = await SettingsService.getLang();
    final res = await http.get(Uri.parse("${API}/api/practice/${id}?lang=${lang.trim()}"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    var json = jsonDecode(res.body);
    setState(() {
      data = json;
      question = data["questions"][index]["question"].toString().trim();
      answer = data["questions"][index]["answer"].toString().trim();
      type = data["questions"][index]["type"];
    });
    print(data);
  }

  void nextQuestion() {
    setState(() {
      index++;
      if (index >= data["questions"].length) {
        isLast = true;
      } else {
        isLast = false;
      }
      print(isLast);
      if (isLast) {
        complete();
      } else {
        question = data["questions"][index]["question"].toString().trim();
        answer = data["questions"][index]["answer"].toString().trim();
        type = data["questions"][index]["type"];
      }
    });
  }

  void complete() async {
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
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    getQuestion();
  }

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case "text":
        return Scaffold(
          appBar: AppBar(
              title: Text("Отработайте навыки")
          ),
          body: PracticeTextPage(answer: answer, question: question, isLast: isLast, isLetter: false, currentquestion: ((1 / data["questions"].length) * (index + 1)),
            onAnswer: () {
              setState(() {
                nextQuestion();
              });
            },
          ),
        );
      case "audio":
        return Scaffold(
          appBar: AppBar(
              title: Text("Отработайте навыки")
          ),
          body: PracticeAudioPage(answer: answer, question: question, isLetter: false, isLast: isLast, currentquestion: (1 / data["questions"].length * (index + 1)),
            onAnswer: () {
              setState(() {
                nextQuestion();
              });
            } ,)
        );
      case "morse":
        return Scaffold(
          appBar: AppBar(
              title: Text("Отработайте навыки")
          ),
            body: PracticeMorsePage(answer: answer, question: question, isLetter: false, isLast: isLast, currentquestion: (1 / data["questions"].length * (index + 1)),
              onAnswer: () {
                setState(() {
                  nextQuestion();
                });
              } ,)
        );
      default: return Scaffold(body: Text("Error"),);
    }
  }
}
