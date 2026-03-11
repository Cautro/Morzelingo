import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/pages/practice/context/practice_context.dart';
import 'package:morzelingo/pages/practice/view/practice_audio_page.dart';
import 'package:morzelingo/pages/practice/view/practice_morse_page.dart';
import 'package:morzelingo/pages/practice/view/practice_text_page.dart';
import 'package:morzelingo/settings_context.dart';

import '../../../config.dart';
import '../../../storage_context.dart';

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

  final Map<String, String> morseToLetterEN = {
    "•—": "A", "—•••": "B", "—•—•": "C", "—••": "D", "•": "E",
    "••—•": "F", "——•": "G", "••••": "H", "••": "I", "•———": "J",
    "—•—": "K", "•—••": "L", "——": "M", "—•": "N", "———": "O",
    "•——•": "P", "——•—": "Q", "•—•": "R", "•••": "S", "—": "T",
    "••—": "U", "•••—": "V", "•——": "W", "—••—": "X", "—•——": "Y",
    "——••": "Z"
  };

  final Map<String, String> morseToLetterRU = {
    '•—': 'А', '—•••': 'Б', '•——': 'В', '——•': 'Г', '—••': 'Д', '•': 'Е', '•••—': 'Ж', '——••': 'З', '••': 'И',
    '•———': 'Й', '—•—': 'К', '•—••': 'Л', '——': 'М', '—•': 'Н', '———': 'О', '•——•': 'П', '•—•': 'Р', '•••': 'С',
    '—': 'Т', '••—': 'У', '••—•': 'Ф', '••••': 'Х', '—•—•': 'Ц', '———•': 'Ч', '————': 'Ш', '——•—': 'Щ', '—•——': 'Ы',
    '—••—': 'Ь', '••—••': 'Э', '••——': 'Ю', '•—•—': 'Я', '/': ' ',  '—————': '0', '•————': '1', '••———': '2', '•••——': '3',
    '••••—': '4', '•••••': '5', '—••••': '6', '——•••': '7', '———••': '8', '————•': '9',
  };

  Map<String, String> morseToLetter = {};

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
    var json = await PracticeContext().getLetterQuestion(index);
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
  }

  void nextQuestion() async {
    var json = await PracticeContext().nextLetterQuestion(data, index, isLast);
    setState(() {
      index = json["index"];
      isLast = json["islast"];

      question = data["questions"][index]["question"].toString().trim();
      answer = data["questions"][index]["answer"].toString().trim();
      type = data["questions"][index]["type"];
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
    print("Q${question} A${answer}");
  }

  void complete() async {
    Navigator.pop(context);
  }

  void checkLang() async {
    String? lang = await SettingsService.getLang();
    setState(() {
      morseToLetter = lang == "en" ? morseToLetterEN : morseToLetterRU;
    });
  }

  @override
  void initState() {
    super.initState();
    getQuestion();
    checkLang();
  }

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case "text":
        return Scaffold(
          appBar: AppBar(
              title: Text("Отработайте букву ${letter}")
          ),
          body: PracticeTextPage(answer: answer, question: question, isLast: isLast, isLetter: true, currentquestion: (1 / data["questions"].length * (index + 1)),
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
          body: PracticeAudioPage(answer: answer, question: question, isLetter: true, isLast: isLast, currentquestion: (1 / data["questions"].length * (index + 1)),
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
            body: PracticeMorsePage(answer: answer, question: question, isLetter: true, isLast: isLast, currentquestion: (1 / data["questions"].length * (index + 1)),
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
