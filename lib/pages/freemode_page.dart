import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/config.dart';
import 'package:morzelingo/storage_context.dart';
import 'dart:convert';
import 'package:morzelingo/widgets/morse_key.dart';

class FreemodePage extends StatefulWidget {

  const FreemodePage({super.key});

  @override
  State<FreemodePage> createState() => _FreemodePageState();
}

class _FreemodePageState extends State<FreemodePage> {
  String decoded = '';
  String question = "";

  @override

  Future<void> getQuestion() async {
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("${API}/api/freemode"),
      headers: {
        'Authorization': 'Bearer $token',
      },);
    final data = jsonDecode(res.body);
    print(data);
    if (res.statusCode == 200) {
      setState(() {
        question = data["question"];
      });
      print(question);
    }
  }

  Future<void> answerHandler() async {
    if (decoded == question) {
      Fluttertoast.showToast(
          msg: "Верно!",
          backgroundColor: Colors.green,
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
      body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsetsGeometry.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        child: Padding(
                          padding: EdgeInsetsGeometry.all(16),
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
