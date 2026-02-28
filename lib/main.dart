import 'package:flutter/material.dart';
import 'package:morzelingo/widgets/morse_key.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: "/",
    routes: {
      "/": (context) => MorseKey()
    },
  ));
}
