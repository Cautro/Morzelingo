import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/pages/practice_audio_page.dart';
import 'package:morzelingo/pages/practice_morse_page.dart';
import 'package:morzelingo/pages/practice_text_page.dart';

import '../config.dart';
import '../storage_context.dart';

class PracticeLettersPage extends StatefulWidget {
  const PracticeLettersPage({super.key});

  @override
  State<PracticeLettersPage> createState() => _PracticeLettersPageState();
}

class _PracticeLettersPageState extends State<PracticeLettersPage> {
  var data;
  var question;
  var answer;
  var type;
  bool isLast = false;
  int index = 0;
  String? letter;

  final Map<String, String> morseToLetter = {
    "•—": "A", "—•••": "B", "—•—•": "C", "—••": "D", "•": "E",
    "••—•": "F", "——•": "G", "••••": "H", "••": "I", "•———": "J",
    "—•—": "K", "•—••": "L", "——": "M", "—•": "N", "———": "O",
    "•——•": "P", "——•—": "Q", "•—•": "R", "•••": "S", "—": "T",
    "••—": "U", "•••—": "V", "•——": "W", "—••—": "X", "—•——": "Y",
    "——••": "Z"
  };


  @override

  String decodeMorse(String morseCode) {
    return morseCode.split('  ').map((word) {
      return word.split(' ').map((char) {
        return morseToLetter[char] ?? '';
      }).join(''); // Склеиваем буквы в слово
    }).join(' '); // Склеиваем слова через пробел
  }

  void getQuestion() async {
    letter = await StorageService.getItem("letter");
    String? token = await StorageService.getItem("token");
    final res = await http.post(Uri.parse("${API}/api/practice?letters=${letter}"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    var json = jsonDecode(res.body);
    setState(() {
      data = json;
      question = data["questions"][index]["question"].toString().trim();
      type = data["questions"][index]["type"].toString();
      switch (type) {
        case "text":
          setState(() {
            answer = question;
          });
        case "audio":
          setState(() {
            answer = decodeMorse(question);
          });
        case "morse":
          setState(() {
            answer = decodeMorse(question);
          });
      }
    });
    print(data);
    print("ans ${answer}");
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
    switch (type) {
      case "text":
        setState(() {
          answer = question;
        });
      case "audio":
        setState(() {
          answer = decodeMorse(question);
        });
      case "morse":
        setState(() {
          answer = decodeMorse(question);
        });
    }
  }

  void complete() async {
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
              title: Text("Отработайте букву ${letter}")
          ),
          body: PracticeTextPage(answer: answer, question: question, isLast: isLast, isLetter: true,
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
              title: Text("Отработайте букву ${letter}")
          ),
          body: PracticeAudioPage(answer: answer, question: question, isLetter: true, isLast: isLast,
            onAnswer: () {
              setState(() {
                nextQuestion();
              });
            } ,)
        );
      case "morse":
        return Scaffold(
          appBar: AppBar(
              title: Text("Отработайте букву ${letter}")
          ),
            body: PracticeMorsePage(answer: answer, question: question, isLetter: true, isLast: isLast,
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
