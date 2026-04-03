import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/freemode/bloc/freemode_bloc.dart';

import '../../../ui/app_ui.dart';

class FreemodeAudioPage extends StatefulWidget {
  final String question;
  final String answer;

  const FreemodeAudioPage({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FreemodeAudioPage> createState() => _FreemodeAudioPageState();
}

class _FreemodeAudioPageState extends State<FreemodeAudioPage> {
  String text = "";
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      appBar: AppBar(title: const Text("Свободный режим · аудио")),
      padding: AppSpacing.pageDense,
      bottomBar: AppDangerButton(
        onPressed: () => context.read<FreemodeBloc>().add(LeaveEvent()),
        child: const Text('Выйти'),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppExerciseInputPanel(
              children: [
                Text(
                  'Прослушайте морзе и переведите',
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
                  decoration: const InputDecoration(labelText: 'Ответ'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppSecondaryButton(
                  onPressed: () {
                    context.read<FreemodeBloc>().add(
                          AudioPlayEvent(question: widget.question),
                        );
                  },
                  child: const Text('Прослушать'),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppPrimaryButton(
                  onPressed: () {
                    context.read<FreemodeBloc>().add(
                          AnswerEvent(answer: widget.answer, text: text),
                        );
                  },
                  child: const Text('Ответить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
