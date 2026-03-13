import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/pages/practice/context/practice_context.dart';

import '../../../app_theme.dart';
import '../../../config.dart';
import '../../../storage_context.dart';
import '../../../theme_controller.dart';
import '../bloc/practice_bloc.dart';

class PracticeMorsePage extends StatefulWidget {
  final String question;
  final String answer;
  final Function onAnswer;
  final bool isLetter;
  final bool isLast;
  final double currentquestion;
  const PracticeMorsePage({super.key, required this.currentquestion, required this.answer, required this.question, required this.onAnswer, required this.isLetter, required this.isLast});

  @override
  State<PracticeMorsePage> createState() => _PracticeMorsePageState();
}

class _PracticeMorsePageState extends State<PracticeMorsePage> {
  String text = "";
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => PracticeBloc(),
        child: BlocListener<PracticeBloc, PracticeState>(
            listener: (context, state) {
              if (state is PracticeMorseAnswerState) {
                Fluttertoast.showToast(
                    msg: state.message,
                    backgroundColor: state.success ? AppTheme.success : AppTheme.error,
                    textColor: Colors.white
                );
                _controller.text = "";
                state.success ? widget.onAnswer() : print('Wrong');
              }
            },
            child: BlocBuilder<PracticeBloc, PracticeState>(
                builder: (context, state) {
                  return Scaffold(
                    body: SafeArea(
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(24),
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: widget.currentquestion,
                              color: themeController.themeMode == ThemeMode.dark ? AppTheme.Darkprimary : AppTheme.primary,
                              minHeight: 12,
                              backgroundColor: themeController.themeMode == ThemeMode.dark ? AppTheme.Darkcard : AppTheme.card,
                              borderRadius: BorderRadiusGeometry.circular(16),
                            ),
                            SizedBox(height: 8,),
                            Container(
                                width: double.infinity,
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Text("Переведите: ${widget.question}", style: Theme.of(context).textTheme.bodyLarge,),
                                                ),
                                              ]
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
                                                context.read<PracticeBloc>().add(PracticeMorseAnswerEvent(text: text, isLetter: widget.isLetter, answer: widget.answer));
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
            )
        )
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
