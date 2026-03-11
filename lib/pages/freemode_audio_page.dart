import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../app_theme.dart';
import '../config.dart';
import '../settings_context.dart';
import '../storage_context.dart';

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

  Future<void> getQuestion() async {
    String? token = await StorageService.getItem("token");
    String? lang = await SettingsService.getLang();
    final res = await http.get(Uri.parse("${API}/api/freemode?mode=morse&lang=${lang}"),
      headers: {
        'Authorization': 'Bearer $token',
      },);
    final data = jsonDecode(res.body);
    print(data);
    setState(() {
      question = data["question"];
      answer = data["answer"];
    });
    _controller.text = "";
  }

  Future<void> playMorse() async {

    if (isPlaying) return;

    isPlaying = true;

    final wpm = await SettingsService.getWpm();
    final timing = MorseTiming(wpm);

    for (int i = 0; i < question.length; i++) {

      final char = question[i];

      if (char == '•') {
        await player.play(AssetSource('sounds/dot.wav'));
        await Future.delayed(Duration(milliseconds: timing.dot));

      } else if (char == '—') {
        await player.play(AssetSource('sounds/dash.wav'));
        await Future.delayed(Duration(milliseconds: timing.dash));

      } else if (char == ' ') {
        await Future.delayed(Duration(milliseconds: timing.letterPause));
      }

      if (i < question.length - 1 && question[i + 1] != ' ' && char != ' ') {
        await Future.delayed(Duration(milliseconds: timing.symbolPause));
      }
    }

    isPlaying = false;
  }

  Future<void> answerHandler() async {
    String? token = await StorageService.getItem("token");
    if (text.trim().toUpperCase() == answer) {
      final resp = await http.post(
        Uri.parse("${API}/api/checker-practice"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(
          {"correct": true},
        ),
      );
      Fluttertoast.showToast(
          msg: "Верно!",
          backgroundColor: AppTheme.success,
          textColor: Colors.white
      );
      final res = await http.post(Uri.parse("${API}/api/freemode/complete"),
        headers: {
          'Authorization': 'Bearer $token',
        },);
      print(res.body);
      setState(() {
        text = '';
      });
      getQuestion();
    } else {
      final res = await http.post(
        Uri.parse("${API}/api/checker-practice"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(
          {"correct": false},
        ),
      );
      Fluttertoast.showToast(
          msg: "Неправильно",
          backgroundColor: AppTheme.error,
          textColor: Colors.white
      );
    }
  }


  @override
  void initState() {
    super.initState();
    getQuestion();
  }

  @override
  Widget build(BuildContext context) {
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
                                playMorse();
                              },
                              child: Text("Прослушать", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),)
                          ),
                        ),
                        SizedBox(height: 16,),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                answerHandler();
                              },
                              child: Text("Ответить", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),)
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
  }
}