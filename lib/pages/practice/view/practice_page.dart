
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/loading_page.dart';
import 'package:morzelingo/pages/practice/view/practice_audio_page.dart';
import 'package:morzelingo/pages/practice/view/practice_morse_page.dart';
import 'package:morzelingo/pages/practice/view/practice_text_page.dart';

import '../bloc/practice_bloc.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  var data;
  var question;
  var answer;
  var type;
  bool isLast = false;
  int index = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PracticeBloc()..add(PracticeGetQuestionEvent()),
      child: BlocListener<PracticeBloc, PracticeState>(
        listener: (context, state) {
          if (state is PracticeGetQuestionState) {
            setState(() {
              data = state.data;
              type = data["questions"][index]["type"];
              question = data["questions"][index]["question"];
              answer = data["questions"][index]["answer"];
            });
          }
          if (state is PracticeNextQuestionState) {
            setState(() {
              question = state.question;
              answer = state.answer;
              type = state.type;
              index = state.index;
              isLast = state.isLast;
            });
          }
          if (state is PracticeCompleteState) {
            Navigator.pop(context);
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<PracticeBloc, PracticeState>(
          builder: (context, state) {
            switch (type) {
              case "text":
                return Scaffold(
                  appBar: AppBar(
                      title: Text("Отработайте навыки")
                  ),
                  body: PracticeTextPage(answer: answer, question: question, isLast: isLast, isLetter: false, currentquestion: ((1 / data["questions"].length) * (index + 1)),
                    onAnswer: () {
                      context.read<PracticeBloc>().add(PracticeNextQuestionEvent(data: data, index: index, isLast: isLast));
                    },
                  ),
                );
              case "audio":
                return Scaffold(
                    appBar: AppBar(
                        title: Text("Отработайте навыки")
                    ),
                    body: PracticeAudioPage(answer: answer, question: question, isLetter: false, isLast: isLast, currentquestion: (1 / data["questions"].length * (index + 1)),
                      onAnswer: () {
                        context.read<PracticeBloc>().add(PracticeNextQuestionEvent(data: data, index: index, isLast: isLast));
                      } ,)
                );
              case "morse":
                return Scaffold(
                    appBar: AppBar(
                        title: Text("Отработайте навыки")
                    ),
                    body: PracticeMorsePage(answer: answer, question: question, isLetter: false, isLast: isLast, currentquestion: (1 / data["questions"].length * (index + 1)),
                      onAnswer: () {
                        context.read<PracticeBloc>().add(PracticeNextQuestionEvent(data: data, index: index, isLast: isLast));
                      } ,)
                );
              default: return LoadingPage();
            }
          },
        ),
      ),
    );

  }
}
