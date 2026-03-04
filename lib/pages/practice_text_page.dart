import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/app_theme.dart';
import 'package:morzelingo/config.dart';
import 'package:morzelingo/storage_context.dart';
import 'dart:convert';
import 'package:morzelingo/widgets/morse_key.dart';

class PracticeTextPage extends StatefulWidget {
  final String question;
  final String answer;
  final Function onAnswer;
  final bool isLast;

  const PracticeTextPage({super.key, required this.answer, required this.question, required this.onAnswer, required this.isLast});

  @override
  State<PracticeTextPage> createState() => _PracticeTextPageState();
}

class _PracticeTextPageState extends State<PracticeTextPage> {
  String decoded = '';

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
    final stats = calculateStats(widget.answer, decoded);
    await sendStats(stats);
  }

  Future<void> answerHandler() async {
    checkAnswer();
    print('data: ${decoded}, ${widget.question}, ${widget.answer}');
    if (decoded.trim() == widget.answer) {
      Fluttertoast.showToast(
          msg: "Верно!",
          backgroundColor: AppTheme.success,
          textColor: Colors.white
      );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
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
                  MorseKeyWidget(onTextDecoded: (text) {
                    setState(() {
                      decoded = text;
                    });
                    print(decoded);
                  }),
                  SizedBox(height: 8,),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          answerHandler();
                        },
                        child: !widget.isLast ? Text("Ответить") : Text("Закончить")
                    ),
                  )
                ],
              ),
            ),
          )
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