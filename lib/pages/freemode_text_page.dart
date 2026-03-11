import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/app_theme.dart';
import 'package:morzelingo/config.dart';
import 'package:morzelingo/settings_context.dart';
import 'package:morzelingo/storage_context.dart';
import 'dart:convert';
import 'package:morzelingo/widgets/morse_key.dart';

class FreemodeTextPage extends StatefulWidget {

  const FreemodeTextPage({super.key});

  @override
  State<FreemodeTextPage> createState() => _FreemodeTextPageState();
}

class _FreemodeTextPageState extends State<FreemodeTextPage> {
  String decoded = '';
  String question = "";
  String answer = '';

  @override

  Future<void> getQuestion() async {
    String? token = await StorageService.getItem("token");
    String? lang = await SettingsService.getLang();
    final res = await http.get(Uri.parse("${API}/api/freemode?mode=text&lang=${lang}"),
      headers: {
        'Authorization': 'Bearer $token',
      },);
    final data = jsonDecode(res.body);
    print(data);
    if (res.statusCode == 200) {
      setState(() {
        question = data["question"];
        answer = data["answer"];
      });
      print(question);
    }
  }

  Future<void> answerHandler() async {
    String? token = await StorageService.getItem("token");
    if (decoded.trim() == answer) {
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
        decoded = '';
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
        title: Text("Свободный режим - текст"),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("Переведите: ${question}"),
                        ),
                      ),
                    ),
                    MorseKeyWidget(onTextDecoded: (text) {
                      setState(() {
                        decoded = text;
                      });
                      print(decoded);
                    }),
                    SizedBox(height: 8,),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            answerHandler();
                          },
                          child: Text("Ответить")
                      ),
                    )
                  ],
                ),
            ),
          )
      ),
    );
  }
}
