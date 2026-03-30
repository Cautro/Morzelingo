
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/practice/bloc/practice_bloc.dart';
import 'package:morzelingo/pages/practice/view/practice_audio_page.dart';
import 'package:morzelingo/pages/practice/view/practice_morse_page.dart';
import 'package:morzelingo/pages/practice/view/practice_text_page.dart';


class PracticeLettersPage extends StatefulWidget {
  const PracticeLettersPage({super.key});

  @override
  State<PracticeLettersPage> createState() => _PracticeLettersPageState();
}

class _PracticeLettersPageState extends State<PracticeLettersPage> {
  var data;
  var question;
  var answer;
  var type;
  bool isLast = false;
  int index = 0;
  String? letter;

  Map<String, String> morseToLetter = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PracticeBloc()..add(LettersGetQuestionEvent()),
      child: BlocListener<PracticeBloc, PracticeState>(
        listener: (context, state) {
          if (state is LettersGetQuestionState) {
            print('aaaaaaaaa${state.data}');
            setState(() {
              data = state.data;
              question = data["questions"][index]["question"].toString().trim();
              type = data["questions"][index]["type"].toString();
              answer = data["questions"][index]["answer"].toString();
            });
          }
          if (state is LettersNextQuestionState) {
            setState(() {
              question = state.question;
              answer = state.answer;
              type = state.type;
              index = state.index;
              isLast = state.isLast;
            });
          }
          if (state is LettersCompleteState) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<PracticeBloc, PracticeState>(
          builder: (context, state) {
            switch (type) {
              case "text":
                return Scaffold(
                  appBar: AppBar(
                      title: Text("Отработайте букву $letter")
                  ),
                  body: PracticeTextPage(answer: answer, question: question, isLast: isLast, isLetter: true, currentquestion: (1 / data["questions"].length * (index + 1)),
                    onAnswer: () {
                      context.read<PracticeBloc>().add(LettersNextQuestionEvent(isLast: isLast, data: data, index: index));
                    },
                  ),
                );
              case "audio":
                return Scaffold(
                    appBar: AppBar(
                        title: Text("Отработайте букву $letter")
                    ),
                    body: PracticeAudioPage(answer: answer, question: question, isLetter: true, isLast: isLast, currentquestion: (1 / data["questions"].length * (index + 1)),
                      onAnswer: () {
                        context.read<PracticeBloc>().add(LettersNextQuestionEvent(isLast: isLast, data: data, index: index));
                      } ,)
                );
              case "morse":
                return Scaffold(
                    appBar: AppBar(
                        title: Text("Отработайте букву $letter")
                    ),
                    body: PracticeMorsePage(answer: answer, question: question, isLetter: true, isLast: isLast, currentquestion: (1 / data["questions"].length * (index + 1)),
                      onAnswer: () {
                        context.read<PracticeBloc>().add(LettersNextQuestionEvent(isLast: isLast, data: data, index: index));
                      } ,)
                );
              default: return Scaffold(body: Text("Error"),);
            }
          },
        ),
      ),
    );
  }
}
