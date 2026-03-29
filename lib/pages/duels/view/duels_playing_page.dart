import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morzelingo/app_theme.dart';
import 'package:morzelingo/pages/duels/bloc/duels_bloc.dart';
import 'package:morzelingo/pages/duels/service/duels_service.dart';
import 'package:morzelingo/widgets/view/morse_key.dart';

import '../../../theme_controller.dart';

class DuelsPlayingPage extends StatefulWidget {
  final List tasks;
  final int currentQuestion;
  final String answer;
  const DuelsPlayingPage({super.key, required this.tasks, required this.currentQuestion, required this.answer});

  @override
  State<DuelsPlayingPage> createState() => _DuelsPlayingPageState();
}

class _DuelsPlayingPageState extends State<DuelsPlayingPage> {
  String answer = "";

  @override
  Future<void> leaveDialog() async {
    final duelsBloc = context.read<DuelsBloc>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Вы уверены что хотите покинуть дуэль?"),
          content: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    duelsBloc.add(LeaveEvent());
                  },
                  child: const Text("Да, покинуть!"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("Не покидать"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Дуэль",),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(child:
      Column(
        children: [
          Expanded(
              child:
              widget.currentQuestion >= widget.tasks.length ? Center(child: Text("Задания кончились"),) :
              widget.tasks[widget.currentQuestion]["type"] == "text" ? TextPage(
                onChange: (text) {
                  setState(() {
                    answer = text;
                  });
                },
                text: widget.tasks[widget.currentQuestion]["question"],
                value: widget.currentQuestion / widget.tasks.length,
              ) :
              widget.tasks[widget.currentQuestion]["type"] == "morse" ? MorsePage(
                onChange: (text) {
                  setState(() {
                    answer = text;
                  });
                },
                text: widget.tasks[widget.currentQuestion]["question"],
                value: widget.currentQuestion / widget.tasks.length,
              ) :
              widget.tasks[widget.currentQuestion]["type"] == "audio" ? AudioPage(
                onChange: (text) {
                  setState(() {
                    answer = text;
                  });
                },
                text: widget.tasks[widget.currentQuestion]["question"],
                value: widget.currentQuestion / widget.tasks.length,
              ) : Center(child: Text("Ожидание"),)
          ),
          Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print("${widget.answer}");
                      context.read<DuelsBloc>().add(AnswerEvent(answer));
                    },
                    child: Text("Ответить"),
                  ),
                ),
                SizedBox(height: 16,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      leaveDialog();
                    },
                    child: Text("Покинуть дуэль"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                  ),
                ),
              ],
            ),
          )
        ],
      )

      ),
    );
  }
}

class TextPage extends StatefulWidget {
  final MorseCallback onChange;
  final double value;
  final String text;
  const TextPage({super.key, required this.text, required this.value, required this.onChange});

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ProgressBar(value: widget.value),
            SizedBox(height: 8,),
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Text("Переведите ${widget.text}", style: Theme.of(context).textTheme.bodyLarge,),
                ),
              ),
            ),
            MorseKeyWidget(onTextDecoded: widget.onChange)
          ],
        ),
    );
  }
}

class MorsePage extends StatefulWidget {
  final ValueChanged<String> onChange;
  final double value;
  final String text;
  const MorsePage({super.key, required this.value, required this.text, required this.onChange});

  @override
  State<MorsePage> createState() => _MorsePageState();
}

class _MorsePageState extends State<MorsePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          ProgressBar(value: widget.value),
          SizedBox(height: 8,),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("Переведите: ${widget.text}", style: Theme.of(context).textTheme.bodyLarge,),
                        ),
                      ]
                  ),
                  SizedBox(height: 16,),
                  TextField(
                    onChanged: widget.onChange,
                    decoration: InputDecoration(labelText: "Ответ"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
}

class AudioPage extends StatefulWidget {
  final ValueChanged<String> onChange;
  final double value;
  final String text;
  const AudioPage({super.key, required this.value, required this.text, required this.onChange});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          ProgressBar(value: widget.value),
          SizedBox(height: 8,),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("Прослушайте морзе и переведите", style: Theme.of(context).textTheme.bodyLarge,),
                        ),
                      ]
                  ),
                  SizedBox(height: 16,),
                  TextField(
                    onChanged: widget.onChange,
                    decoration: InputDecoration(labelText: "Ответ"),
                  ),
                  SizedBox(height: 16,),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        context.read<DuelsBloc>().add(PlayMorseEvent(question: widget.text.toString()));
                      },
                      child: Text("Прослушать"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
}


class ProgressBar extends StatelessWidget {
  final double value;
  const ProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      color: themeController.themeMode == ThemeMode.dark ? AppTheme.Darkprimary : AppTheme.primary,
      minHeight: 12,
      backgroundColor: themeController.themeMode == ThemeMode.dark ? AppTheme.Darkcard : AppTheme.card,
      borderRadius: BorderRadiusGeometry.circular(16),
    );
  }
}
