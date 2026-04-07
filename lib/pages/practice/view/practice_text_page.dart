import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/practice/bloc/practice_bloc.dart';
import 'package:morzelingo/widgets/view/morse_key.dart';

import '../../../ui/app_ui.dart';

class PracticeTextPage extends StatefulWidget {
  final String question;
  final String answer;
  final bool isLast;
  final bool isLetter;
  final double currentquestion;

  const PracticeTextPage({
    super.key,
    required this.answer,
    required this.question,
    required this.isLast,
    required this.isLetter,
    required this.currentquestion,
  });

  @override
  State<PracticeTextPage> createState() => _PracticeTextPageState();
}

class _PracticeTextPageState extends State<PracticeTextPage> {
  String text = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                context.read<PracticeBloc>().add(LeaveEvent());
              }
            },
            child: Scaffold(
              appBar: AppBar(title: Text("Просмотр")),
              body: Center(child: Text("Контент")),
            ),
          ),
          AppProgressBar(value: widget.currentquestion),
          const SizedBox(height: AppSpacing.md),
          AppExercisePrompt(
            title: 'Переведите',
            subtitle: widget.question,
          ),
          const SizedBox(height: AppSpacing.md),
          MorseKeyWidget(
            onTextDecoded: (value) {
              setState(() {
                text = value;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
            onPressed: () {
              context.read<PracticeBloc>().add(
                   AnswerEvent(text: text)
                  );
            },
            child: Text(widget.isLast ? "Закончить" : "Ответить"),
          ),
        ],
      ),
    );
  }
}