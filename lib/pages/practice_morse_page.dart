import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../app_theme.dart';
import '../config.dart';
import '../storage_context.dart';

class PracticeMorsePage extends StatefulWidget {
  final String question;
  final String answer;
  final Function onAnswer;
  const PracticeMorsePage({super.key, required this.answer, required this.question, required this.onAnswer});

  @override
  State<PracticeMorsePage> createState() => _PracticeMorsePageState();
}

class _PracticeMorsePageState extends State<PracticeMorsePage> {
  String text = "";
  TextEditingController _controller = TextEditingController();

  @override

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

  void checkAnswer() async {
    final stats = calculateStats(widget.answer, text);
    await sendStats(stats);
  }

  Future<void> answerHandler() async {
    checkAnswer();
    if (text.trim().toUpperCase() == widget.answer) {
      Fluttertoast.showToast(
          msg: "Верно!",
          backgroundColor: AppTheme.success,
          textColor: Colors.white
      );
      setState(() {
        _controller.text = "";
      });
      widget.onAnswer();
    } else {
      Fluttertoast.showToast(
          msg: "Неправильно",
          backgroundColor: AppTheme.error,
          textColor: Colors.white
      );
    }
  }


  @override
  void initState() {
    super.initState();
    print(widget.question);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(24),
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text("Переведите: ${widget.question}"),
                              ),
                            ),
                          ),
                          SizedBox(height: 16,),
                          TextField(
                            controller: _controller,
                            onChanged: (value) {
                              setState(() {
                                text = value;
                                print(text);
                              });
                            },
                            decoration: InputDecoration(labelText: "Ответ"),
                          ),
                          SizedBox(height: 16,),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () {
                                  answerHandler();
                                },
                                child: Text("Ответить", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),)
                            ),
                          )
                        ],
                      ),
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SymbolUpdate {
  final String symbol;
  int correct;
  int wrong;

  SymbolUpdate({
    required this.symbol,
    this.correct = 0,
    this.wrong = 0,
  });

  Map<String, dynamic> toJson() => {
    "symbol": symbol,
    "correct": correct,
    "wrong": wrong,
  };
}
