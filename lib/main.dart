import 'package:flutter/material.dart';
import 'package:morzelingo/pages/login_page.dart';
import 'package:morzelingo/pages/question_page.dart';
import "package:morzelingo/pages/home_page.dart";
import 'package:morzelingo/pages/register_page.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: "/login",
    routes: {
      "/home": (context) => HomeTabsPage(),
      "/register": (context) => RegisterPage(),
      "/login": (context) => LoginPage(),
      "/question": (context) => QuestionPage()
    },
  ));
}
