import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/app_theme.dart';
import 'package:morzelingo/config.dart';
import 'package:morzelingo/pages/freemode/bloc/freemode_bloc.dart';
import 'package:morzelingo/settings_context.dart';
import 'package:morzelingo/storage_context.dart';
import 'dart:convert';
import 'package:morzelingo/widgets/view/morse_key.dart';

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>  FreemodeBloc()..add(TextGetEvent()),
      child: BlocListener<FreemodeBloc, FreemodeState>(
        listener: (context, state) {
          if (state is TextGetState) {
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
          if (state is TextAnswerState) {
            Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: state.success ? AppTheme.success : AppTheme.error,
                textColor: Colors.white
            );
            setState(() {
              decoded = '';
            });
          }
        },
        child: BlocBuilder<FreemodeBloc, FreemodeState>(
          builder: (context, state) {
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
                                  context.read<FreemodeBloc>().add(TextAnswerEvent(answer: answer, decoded: decoded));
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
          },
        ),
      ),
    );
  }
}
