import 'package:flutter/material.dart';
import 'package:morzelingo/widgets/morse_key.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  String decoded = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(padding: EdgeInsetsGeometry.only(top: 60)),
          Text(decoded),
          MorseKeyWidget(
            onTextDecoded: (text) {
              // callback с расшифрованным текстом
              setState(() {
                decoded = text;
              });
            },
          ),
        ],
      ),
    );
  }
}
