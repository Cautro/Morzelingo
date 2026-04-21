import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../ui/app_ui.dart';
import '../bloc/practice_bloc.dart';

class PracticeMorsePage extends StatefulWidget {
  final String question;
  final String answer;
  final bool isLetter;
  final bool isLast;
  final double currentquestion;

  const PracticeMorsePage({
    super.key,
    required this.currentquestion,
    required this.answer,
    required this.question,
    required this.isLetter,
    required this.isLast,
  });

  @override
  State<PracticeMorsePage> createState() => _PracticeMorsePageState();
}

class _PracticeMorsePageState extends State<PracticeMorsePage> {
  String text = "";
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppProgressBar(value: widget.currentquestion),
          const SizedBox(height: AppSpacing.md),
          AppExerciseInputPanel(
            children: [
              Text(
                "Переведите: ${widget.question}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    text = value;
                  });
                },
                decoration: const InputDecoration(labelText: "Ответ"),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                onPressed: () {
                  context.read<PracticeBloc>().add(
                      AnswerEvent(text: text)
                  );
                },
                child: Text(!widget.isLast ? "Ответить" : "Закончить"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}