import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:morzelingo/config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String login = '';
  String password = '';
  String email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(20)),
              Text("Регистрация"),
              Padding(padding: EdgeInsetsGeometry.only(top: 10)),
              Text("Логин",),
              TextField(
                onChanged: (text) {
                  setState(() {
                    login = text;
                  });
                },
              ),
              Text("Email"),
              Padding(padding: EdgeInsetsGeometry.only(top: 10)),
              TextField(
                onChanged: (text) {
                  setState(() {
                    email = text;
                  });
                },
              ),
              Text("Пароль"),
              Padding(padding: EdgeInsetsGeometry.only(top: 10)),
              TextField(
                onChanged: (text) {
                  setState(() {
                    password = text;
                  });
                },
              ),
              TextButton(
                onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
              },
                  child: Text("Войти в аккаунт")
              ),
              Padding(padding: EdgeInsetsGeometry.only(top: 10)),
              ElevatedButton(
                  onPressed: () async {
                    final res = await http.post(
                      Uri.parse("${API}/api/register"),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({"username": login, "password": password, "email": email}),
                    );
                    print(res.statusCode);
                    print(res.body);
                    if (res.statusCode == 200) {
                      Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
                      final data = jsonDecode(res.body);
                      print("Успешно: $data");
                    }
                  },
                  child: Text("Зарегистрироваться")
              )
            ],
          ),
        )
    );
  }
}
