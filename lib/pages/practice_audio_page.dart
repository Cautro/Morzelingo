import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../app_theme.dart';
import '../config.dart';
import '../storage_context.dart';

class PracticeAudioPage extends StatefulWidget {
  final String question;
  final String answer;
  final Function onAnswer;
  final bool isLetter;
  final bool isLast;
  const PracticeAudioPage({super.key, required this.answer, required this.question, required this.onAnswer, required this.isLetter, required this.isLast});

  @override
  State<PracticeAudioPage> createState() => _PracticeAudioPageState();
}

class _PracticeAudioPageState extends State<PracticeAudioPage> {
  final player = AudioPlayer();

  String text = "";
  TextEditingController _controller = TextEditingController();

  @override

  Future<void> playMorse() async {
    const int dotDuration = 200;   // миллисекунды для точки
    const int dashDuration = 600;  // тире = 3 точки
    const int symbolPause = 100;   // пауза между символами
    const int letterPause = 600;   // пауза между буквами (3 точки)
    const int wordPause = 1400;    // пауза между словами (7 точек)

    for (int i = 0; i < widget.question.length; i++) {
      final char = widget.question[i];
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
      if (i < widget.question.length - 1 && widget.question[i + 1] != ' ' && char != ' ') {
        await Future.delayed(Duration(milliseconds: symbolPause));
      }
    }
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

  void checkAnswer() async {
    final stats = calculateStats(widget.answer, text);
    await sendStats(stats);
  }

  Future<void> answerHandler() async {
    String? token = await StorageService.getItem("token");
    if (!widget.isLetter) {
      checkAnswer();
    }
    if (text.trim().toUpperCase() == widget.answer) {
      if (!widget.isLetter) {
        final res = await http.post(
          Uri.parse("${API}/api/checker-practice"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(
            {"correct": true},
          ),
        );
      }
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
      if (!widget.isLetter) {
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
      }
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
                                  playMorse();
                                },
                                child: Text("Прослушать", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),)
                            ),
                          ),
                          SizedBox(height: 16,),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () {
                                  answerHandler();
                                },
                                child:  Text( !widget.isLast ? "Ответить" : "Закончить", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white), )
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
