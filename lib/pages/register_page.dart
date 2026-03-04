import 'dart:convert';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/app_theme.dart';
import 'package:morzelingo/config.dart';
import 'package:morzelingo/storage_context.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String login = '';
  String password = '';
  String confirmpassword = '';
  String email = '';


  void registerHandler() async {
    if (login == "" || password == "" || email == "" || confirmpassword == "") {
      Fluttertoast.showToast(
          msg: "Пожалуйста введите логин, email и пароль",
          backgroundColor: Colors.red,
          textColor: Colors.white
      );
      return;
    } else if (password != confirmpassword) {
      Fluttertoast.showToast(
          msg: "Пожалуйста введите одинаковые пароли",
          backgroundColor: Colors.red,
          textColor: Colors.white
      );
      return;
    }
    final res = await http.post(Uri.parse("${API}/api/register"),
        headers: {"Content-Type": "application/json",},
        body: jsonEncode({
          "username": login,
          "email": email,
          "password": password
        })
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await StorageService.setItem("token", data["token"]);
      Fluttertoast.showToast(
          msg: "Регистрация успешна",
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
                                });
                              },
                              onPasswordChanged: (value) {
                                setState(() {
                                  password = value;
                                });
                              },
                              onPasswordConfirmChanged: (value) {
                                setState(() {
                                  confirmpassword = value;
                                });
                              },
                              onEmailChanged: (value) {
                                setState(() {
                                  email = value;
                                });
                              } ,
                            ),
                            SizedBox(height: 24),
                            SizedBox(
                              child: _RegisterButton(
                                  registerHandler: registerHandler
                              ),
                              width: double.infinity,
                            ),
                            SizedBox(height: 8),
                            _LoginButton()
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
  final Function(String) onPasswordConfirmChanged;
  final Function(String) onEmailChanged;

  const _LoginForm({
    super.key,
    required this.onLoginChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onPasswordConfirmChanged
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
          onChanged: onEmailChanged,
          decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              labelText: "Email"
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
        SizedBox(height: 16),
        TextField(
          onChanged: onPasswordConfirmChanged,
          obscureText: true,
          decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              labelText: "Подтвердите пароль"
          ),
        ),
      ],
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final Function() registerHandler;

  const _RegisterButton({
    super.key,
    required this.registerHandler
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: registerHandler,
        child: Text("Зарегистрироваться", style: TextStyle(),),
        style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16))
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, "/login");
        },
        child: Text("Уже есть аккаунт? Войти")
    );
  }
}
