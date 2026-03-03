import 'package:flutter/material.dart';
import 'package:morzelingo/pages/freemode_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'app_theme.dart';

void main() {
  runApp(MaterialApp(
    theme: AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,
    initialRoute: "/login",
    routes: {
      "/home": (context) => HomeTabsPage(),
      "/register": (context) => RegisterPage(),
      "/login": (context) => LoginPage(),
      "/freemode": (context) => FreemodePage(),
      "/profile": (context) => ProfilePage(),
    },
  ));
}