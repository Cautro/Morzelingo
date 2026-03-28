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
              widget.tasks[widget.currentQuestion]["type"] == "text" ? SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: widget.currentQuestion.toDouble() / widget.tasks.length,
                      color: themeController.themeMode == ThemeMode.dark ? AppTheme.Darkprimary : AppTheme.primary,
                      minHeight: 12,
                      backgroundColor: themeController.themeMode == ThemeMode.dark ? AppTheme.Darkcard : AppTheme.card,
                      borderRadius: BorderRadiusGeometry.circular(16),
                    ),
                    SizedBox(height: 8,),
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Text("Переведите ${widget.tasks[widget.currentQuestion]["question"]}", style: Theme.of(context).textTheme.bodyLarge,),
                        ),
                      ),
                    ),
                    MorseKeyWidget(onTextDecoded: (text) {setState(() {answer = text;});} )
                  ],
                ),
              ) :
              widget.tasks[widget.currentQuestion]["type"] == "morse" ? SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: widget.currentQuestion.toDouble() / widget.tasks.length,
                      color: themeController.themeMode == ThemeMode.dark ? AppTheme.Darkprimary : AppTheme.primary,
                      minHeight: 12,
                      backgroundColor: themeController.themeMode == ThemeMode.dark ? AppTheme.Darkcard : AppTheme.card,
                      borderRadius: BorderRadiusGeometry.circular(16),
                    ),
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
                                    child: Text("Переведите: ${widget.tasks[widget.currentQuestion]["question"]}", style: Theme.of(context).textTheme.bodyLarge,),
                                  ),
                                ]
                            ),
                            SizedBox(height: 16,),
                            TextField(
                              onChanged: (value) {
                                setState(() {
                                  answer = value;
                                });
                              },
                              decoration: InputDecoration(labelText: "Ответ"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              ) :
              widget.tasks[widget.currentQuestion]["type"] == "audio" ? SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: widget.currentQuestion.toDouble() / widget.tasks.length,
                      color: themeController.themeMode == ThemeMode.dark ? AppTheme.Darkprimary : AppTheme.primary,
                      minHeight: 12,
                      backgroundColor: themeController.themeMode == ThemeMode.dark ? AppTheme.Darkcard : AppTheme.card,
                      borderRadius: BorderRadiusGeometry.circular(16),
                    ),
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
                              onChanged: (value) {
                                setState(() {
                                  answer = value;
                                });
                              },
                              decoration: InputDecoration(labelText: "Ответ"),
                            ),
                            SizedBox(height: 16,),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await DuelsService().playMorseAudio(
                                    widget.tasks[widget.currentQuestion]["question"],
                                  );
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