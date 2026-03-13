import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/pages/freemode/bloc/freemode_bloc.dart';

import '../../../app_theme.dart';
import '../../../config.dart';
import '../../../settings_context.dart';
import '../../../storage_context.dart';

class FreemodeAudioPage extends StatefulWidget {
  const FreemodeAudioPage({super.key});

  @override
  State<FreemodeAudioPage> createState() => _FreemodeAudioPageState();
}

class _FreemodeAudioPageState extends State<FreemodeAudioPage> {
  final player = AudioPlayer();
  String question = '';
  String answer = '';
  String text = "";
  bool isPlaying = false;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    player.stop();
    AudioPlayer().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FreemodeBloc()..add(AudioGetEvent()),
      child: BlocListener<FreemodeBloc, FreemodeState>(
        listener: (context, state) {
          if (state is AudioGetState) {
              if (state.success) {
                setState(() {
                  question = state.question;
                  answer = state.answer;
                });
              } else {
                Fluttertoast.showToast(
                  msg: "Ошибка сервера",
                  backgroundColor: AppTheme.error,
                  textColor: Colors.white
                );
              }
          }
          if (state is AudioAnswerState) {
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: state.success ? AppTheme.success : AppTheme.error,
                textColor: Colors.white
              );
              _controller.text = '';
          }
          if (state is AudioPlayState) {
            isPlaying = state.isPlaying;
          }
        },
        child: BlocBuilder<FreemodeBloc, FreemodeState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Свободный режим - аудио"),
              ),
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsetsGeometry.all(24),
                  child: Column(
                    children: [
                      Container(
                          width: double.infinity,
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  SizedBox(height: 16,),
                                  Text("Прослушайте морзе и переведите", style: Theme.of(context).textTheme.bodyLarge,),
                                  SizedBox(height: 16,),
                                  TextField(
                                    controller: _controller,
                                    onChanged: (value) {
                                      setState(() {
                                        text = value;
                                        print(text);
                                      });
                                    },
                                    decoration: InputDecoration(labelText: "Ответ"),
                                  ),
                                  SizedBox(height: 16,),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          context.read<FreemodeBloc>().add(AudioPlayEvent(isPlaying: isPlaying, question: question));
                                        },
                                        child: Text("Прослушать", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),)
                                    ),
                                  ),
                                  SizedBox(height: 16,),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          context.read<FreemodeBloc>().add(AudioAnswerEvent(answer: answer, decoded: text));
                                        },
                                        child: Text("Ответить", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),)
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

  }
}