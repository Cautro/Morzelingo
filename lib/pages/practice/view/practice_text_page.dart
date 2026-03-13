import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/app_theme.dart';
import 'package:morzelingo/config.dart';
import 'package:morzelingo/pages/practice/bloc/practice_bloc.dart';
import 'package:morzelingo/pages/practice/context/practice_context.dart';
import 'package:morzelingo/storage_context.dart';
import 'dart:convert';
import 'package:morzelingo/widgets/view/morse_key.dart';

import '../../../theme_controller.dart';

class PracticeTextPage extends StatefulWidget {
  final String question;
  final String answer;
  final Function onAnswer;
  final bool isLast;
  final bool isLetter;
  final double currentquestion;

  const PracticeTextPage({super.key, required this.answer, required this.question, required this.onAnswer, required this.isLast, required this. isLetter, required this.currentquestion});

  @override
  State<PracticeTextPage> createState() => _PracticeTextPageState();
}

class _PracticeTextPageState extends State<PracticeTextPage> {
  String decoded = '';

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
          if (state is PracticeTextAnswerState) {
            Fluttertoast.showToast(
              msg: state.message,
              backgroundColor: state.success ? AppTheme.success : AppTheme.error,
              textColor: Colors.white
            );
            state.success ? widget.onAnswer() : print('Wrong');
          }
        },
        child: BlocBuilder<PracticeBloc, PracticeState>(
          builder: (context, state) {
            return Scaffold(
              body: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16),
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
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text("Переведите: ${widget.question}", style: Theme.of(context).textTheme.bodyLarge,),
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
                                  context.read<PracticeBloc>().add(PracticeTextAnswerEvent(decoded: decoded, isLetter: widget.isLetter, answer: widget.answer));
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
          },
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