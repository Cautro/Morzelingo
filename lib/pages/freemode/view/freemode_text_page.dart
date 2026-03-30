import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/freemode/bloc/freemode_bloc.dart';
import 'package:morzelingo/widgets/view/morse_key.dart';

class FreemodeTextPage extends StatefulWidget {
  final String question;
  final String answer;
  const FreemodeTextPage({super.key, required this.question, required this.answer});

  @override
  State<FreemodeTextPage> createState() => _FreemodeTextPageState();
}

class _FreemodeTextPageState extends State<FreemodeTextPage> {
  String decoded = '';

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
                        child: Text("Переведите: ${widget.question}"),
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
                          context.read<FreemodeBloc>().add(AnswerEvent(answer: widget.answer, text: decoded));
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
