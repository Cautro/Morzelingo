import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/pages/practice/context/practice_context.dart';
import 'package:morzelingo/pages/practice/view/practice_audio_page.dart';
import 'package:morzelingo/pages/practice/view/practice_morse_page.dart';
import 'package:morzelingo/pages/practice/view/practice_text_page.dart';

import '../../../config.dart';
import '../../../settings_context.dart';
import '../../../storage_context.dart';

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
    var res = await PracticeContext().getPracticeQuestion();

    setState(() {
      data = res["data"];
      question = data["questions"][index]["question"].toString().trim();
      answer = data["questions"][index]["answer"].toString().trim();
      type = data["questions"][index]["type"];
    });
    print('${data}');
  }

  void nextQuestion() async {
   isLast ? complete() : print('notlast');
   var res = await PracticeContext().nextPracticeQuestion(data, index, isLast);
   setState(() {
     question = res["question"];
     answer = res["answer"];
     type = res["type"];
     isLast = res["islast"];
     index = res["index"];
   });
  }

  void complete() async {
    PracticeContext().completeLesson();
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
