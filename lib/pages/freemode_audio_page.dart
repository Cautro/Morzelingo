import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../app_theme.dart';
import '../config.dart';
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
  TextEditingController _controller = TextEditingController();

  @override

  Future<void> getQuestion() async {
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("${API}/api/freemode?mode=morse"),
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
    const int dotDuration = 200;   // миллисекунды для точки
    const int dashDuration = 600;  // тире = 3 точки
    const int symbolPause = 100;   // пауза между символами
    const int letterPause = 600;   // пауза между буквами (3 точки)
    const int wordPause = 1400;    // пауза между словами (7 точек)

    for (int i = 0; i < question.length; i++) {
      final char = question[i];
      if (char == '.') {
        await player.play(AssetSource('sounds/dot.wav'));
        await Future.delayed(Duration(milliseconds: dotDuration));
      } else if (char == '-') {
        await player.play(AssetSource('sounds/dash.wav'));
        await Future.delayed(Duration(milliseconds: dashDuration));
      } else if (char == ' ') {
        // если пробел, это конец буквы или слова
        await Future.delayed(Duration(milliseconds: letterPause));
      }

      // пауза между символами (если это не последний символ и не пробел)
      if (i < question.length - 1 && question[i + 1] != ' ' && char != ' ') {
        await Future.delayed(Duration(milliseconds: symbolPause));
      }
    }
  }

  Future<void> answerHandler() async {
    if (text.trim().toUpperCase() == answer) {
      Fluttertoast.showToast(
          msg: "Верно!",
          backgroundColor: AppTheme.success,
          textColor: Colors.white
      );
      String? token = await StorageService.getItem("token");
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
