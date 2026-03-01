import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:morzelingo/config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String login = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(20)),
              Text("Вход в аккаунт"),
              Padding(padding: EdgeInsetsGeometry.only(top: 10)),
              Text("Логин"),
              TextField(
                onChanged: (text) {
                  setState(() {
                    login = text;
                  });
                },
              ),
              Padding(padding: EdgeInsetsGeometry.only(top: 10)),
              Text("Пароль"),
              TextField(
                onChanged: (text) {
                  setState(() {
                    password = text;
                  });
                },
              ),
              Padding(padding: EdgeInsetsGeometry.only(top: 10)),
              TextButton(
                onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, "/register", (route) => true);
              },
                  child: Text("Зарегестрироваться")
              ),
              ElevatedButton(
                  onPressed: () async {
                    final res = await http.post(
                      Uri.parse("${API}/api/login"),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({"username": login, "password": password}),
                    );
                    print(res.statusCode);
                    print(res.body);
                    if (res.statusCode == 200) {
                      Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
                      final data = jsonDecode(res.body);
                      print("Успешно: $data");
                    }
                  },
                  child: Text("Войти")
              )
            ],
          ),
      )
    );
  }
}
