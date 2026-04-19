import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/freemode/bloc/freemode_bloc.dart';
import 'package:morzelingo/widgets/view/morse_key.dart';

import '../../../ui/app_ui.dart';

class FreemodeTextPage extends StatefulWidget {
  final String question;
  final String answer;

  const FreemodeTextPage({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FreemodeTextPage> createState() => _FreemodeTextPageState();
}

class _FreemodeTextPageState extends State<FreemodeTextPage> {
  String decoded = '';

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      appBar: AppBar(title: const Text("Свободный режим · текст")),
      padding: AppSpacing.pageDense,
      bottomBar: AppDangerButton(
        onPressed: () => context.read<FreemodeBloc>().add(const LeaveEvent()),
        child: const Text('Выйти'),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppExercisePrompt(
              title: 'Переведите',
              subtitle: widget.question,
            ),
            const SizedBox(height: AppSpacing.md),
            MorseKeyWidget(
              onTextDecoded: (text) {
                setState(() {
                  decoded = text;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              onPressed: () {
                context.read<FreemodeBloc>().add(
                      AnswerEvent(answer: widget.answer, text: decoded),
                    );
              },
              child: const Text('Ответить'),
            ),
          ],
        ),
      ),
    );
  }
}
