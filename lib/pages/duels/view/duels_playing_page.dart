import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/duels/bloc/duels_bloc.dart';
import 'package:morzelingo/widgets/view/morse_key.dart';

import '../../../ui/app_ui.dart';

class DuelsPlayingPage extends StatefulWidget {
  final List tasks;
  final int currentQuestion;
  final String answer;

  const DuelsPlayingPage({
    super.key,
    required this.tasks,
    required this.currentQuestion,
    required this.answer,
  });

  @override
  State<DuelsPlayingPage> createState() => _DuelsPlayingPageState();
}

class _DuelsPlayingPageState extends State<DuelsPlayingPage> {
  String answer = "";

  Future<void> leaveDialog() async {
    final duelsBloc = context.read<DuelsBloc>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AppConfirmationDialog(
          title: 'Покинуть дуэль?',
          message: 'Если выйти сейчас, текущий матч завершится без возможности продолжения.',
          confirmLabel: 'Да, покинуть',
          cancelLabel: 'Остаться',
          destructive: true,
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            duelsBloc.add(const LeaveEvent());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.currentQuestion >= widget.tasks.length
        ? const AppEmptyState(
            icon: Icons.task_alt_rounded,
            title: 'Задания закончились',
            subtitle: 'Дуэль автоматически завершится после обработки ответов.',
          )
        : widget.tasks[widget.currentQuestion]["type"] == "text"
            ? TextPage(
                onChange: (text) {
                  setState(() {
                    answer = text;
                  });
                },
                text: widget.tasks[widget.currentQuestion]["question"],
                value: widget.currentQuestion / widget.tasks.length,
              )
            : widget.tasks[widget.currentQuestion]["type"] == "morse"
                ? MorsePage(
                    onChange: (text) {
                      setState(() {
                        answer = text;
                      });
                    },
                    text: widget.tasks[widget.currentQuestion]["question"],
                    value: widget.currentQuestion / widget.tasks.length,
                  )
                : widget.tasks[widget.currentQuestion]["type"] == "audio"
                    ? AudioPage(
                        onChange: (text) {
                          setState(() {
                            answer = text;
                          });
                        },
                        text: widget.tasks[widget.currentQuestion]["question"],
                        value: widget.currentQuestion / widget.tasks.length,
                      )
                    : const AppEmptyState(
                        icon: Icons.hourglass_empty_rounded,
                        title: 'Ожидание',
                      );

    return AppPageScaffold(
      appBar: AppBar(
        title: const Text("Дуэль"),
        automaticallyImplyLeading: false,
      ),
      padding: AppSpacing.pageDense,
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppPrimaryButton(
            onPressed: () {
              context.read<DuelsBloc>().add(AnswerEvent(answer: answer));
            },
            child: const Text('Ответить'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppDangerButton(
            onPressed: () {
              leaveDialog();
            },
            child: const Text('Покинуть дуэль'),
          ),
        ],
      ),
      child: content,
    );
  }
}

class TextPage extends StatelessWidget {
  final MorseCallback onChange;
  final double value;
  final String text;

  const TextPage({
    super.key,
    required this.text,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProgressBar(value: value),
          const SizedBox(height: AppSpacing.md),
          AppExercisePrompt(
            title: 'Переведите',
            subtitle: text,
          ),
          const SizedBox(height: AppSpacing.md),
          MorseKeyWidget(onTextDecoded: onChange),
        ],
      ),
    );
  }
}


class MorsePage extends StatelessWidget {
  final ValueChanged<String> onChange;
  final double value;
  final String text;

  const MorsePage({
    super.key,
    required this.value,
    required this.text,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProgressBar(value: value),
          const SizedBox(height: AppSpacing.md),
          AppExerciseInputPanel(
            children: [
              Text(
                "Переведите: $text",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                onChanged: onChange,
                decoration: const InputDecoration(labelText: "Ответ"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class AudioPage extends StatelessWidget {
  final ValueChanged<String> onChange;
  final double value;
  final String text;

  const AudioPage({
    super.key,
    required this.value,
    required this.text,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProgressBar(value: value),
          const SizedBox(height: AppSpacing.md),
          AppExerciseInputPanel(
            children: [
              Text(
                "Прослушайте морзе и переведите",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                onChanged: onChange,
                decoration: const InputDecoration(labelText: "Ответ"),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSecondaryButton(
                onPressed: () async {
                  context.read<DuelsBloc>().add(
                    PlayMorseEvent(question: text.toString()),
                  );
                },
                child: const Text('Прослушать'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class ProgressBar extends StatelessWidget {
  final double value;

  const ProgressBar({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AppProgressBar(value: value);
  }
}
