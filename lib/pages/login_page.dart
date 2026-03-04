import 'dart:convert';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/app_theme.dart';
import 'package:morzelingo/config.dart';
import 'package:morzelingo/storage_context.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String login = '';
  String password = '';


  void loginHandler() async {
    if (login == "" || password == "") {
      Fluttertoast.showToast(
          msg: "Пожалуйста введите логин и пароль",
          backgroundColor: AppTheme.error,
          textColor: Colors.white
      );
      return;
    }
    final res = await http.post(Uri.parse("${API}/api/login"),
      headers: {"Content-Type": "application/json",},
      body: jsonEncode({
        "username": login,
        "password": password
      })
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await StorageService.setItem("token", data["token"]);

      Fluttertoast.showToast(
          msg: "Вход успешен",
          backgroundColor: AppTheme.success,
          textColor: Colors.white
      );
      print(data);
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      Fluttertoast.showToast(
          msg: data["error"],
          backgroundColor: AppTheme.error,
          textColor: Colors.white
      );
      print(res.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsetsGeometry.all(16),
              child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
                    child: Padding(
                      padding: EdgeInsetsGeometry.all(24),
                      child: Column(
                        children: [
                          _LoginForm(
                            onLoginChanged: (value) {
                              setState(() {
                                login = value;
                                print(login);
                              });
                            },
                            onPasswordChanged: (value) {
                              setState(() {
                                password = value;
                                print(password);
                              });
                            },
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            child: _LoginButton(
                              loginHandler: loginHandler
                            ),
                            width: double.infinity,
                          ),
                          SizedBox(height: 8),
                          _RegisterButton()
                        ],
                      ),
                    ),
                  ),
              )
            )
          )
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final Function(String) onLoginChanged;
  final Function(String) onPasswordChanged;

  const _LoginForm({
    super.key,
    required this.onLoginChanged,
    required this.onPasswordChanged
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: onLoginChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            labelText: "Имя пользователя"
          ),
        ),
        SizedBox(height: 16),
        TextField(
          onChanged: onPasswordChanged,
          obscureText: true,
          decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              labelText: "Пароль"
          ),
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  final Function() loginHandler;

  const _LoginButton({
    super.key,
    required this.loginHandler
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: loginHandler,
        child: Text("Войти", style: TextStyle(),),
        style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16))
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, "/register");
        },
        child: Text("Нет аккаунта? Зарегистрироваться")
    );
  }
}
