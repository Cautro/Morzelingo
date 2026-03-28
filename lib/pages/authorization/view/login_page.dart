import 'dart:convert';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/app_theme.dart';
import 'package:morzelingo/config.dart';
import 'package:morzelingo/settings_context.dart';
import 'package:morzelingo/storage_context.dart';
import '../bloc/authorization_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String login = '';
  String password = '';


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthorizationBloc()..add(CheckLoginedEvent()),
      child: BlocBuilder<AuthorizationBloc, AuthorizationState>(
        builder: (context, state) {
          return BlocListener<AuthorizationBloc, AuthorizationState>(
            listener: (context, state) {
              print("STATE CHANGED: ${state.runtimeType}");

              if (state is CheckLoginedState) {
                if (state.success == true) {
                  Navigator.pushReplacementNamed(context, "/home");
                }
              }

              if (state is LoginState) {
                print('${state.message}, ${state.success}');
                if (state.success == true) {
                  Fluttertoast.showToast(
                      msg: state.message,
                      backgroundColor: AppTheme.success,
                      textColor: Colors.white
                  );
                  Navigator.pushReplacementNamed(context, "/home");
                } else {
                  Fluttertoast.showToast(
                      msg: state.message,
                      backgroundColor: AppTheme.error,
                      textColor: Colors.white
                  );
                }
              }
            },
            child: Scaffold(
              body: SafeArea(
                  child: Center(
                      child: SingleChildScrollView(
                          padding: EdgeInsets.all(16),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 400),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
                              child: Padding(
                                padding: EdgeInsetsGeometry.all(24),
                                child: Column(
                                  children: [
                                    TextField(
                                      onChanged: (value) => login = value,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                          labelText: "Имя пользователя"
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    TextField(
                                      onChanged: (value) => password = value,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                          labelText: "Пароль"
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    SizedBox(
                                      child: ElevatedButton(
                                          onPressed: () {
                                            context.read<AuthorizationBloc>().add(
                                              LoginEvent(login: login, password: password),
                                            );
                                          },
                                          child: Text("Войти", style: TextStyle(),),
                                          style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16))
                                      ),
                                      width: double.infinity,
                                    ),
                                    SizedBox(height: 8),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacementNamed(context, "/register");
                                        },
                                        child: Text("Нет аккаунта? Зарегистрироваться")
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                      )
                  )
              ),
            ),
          );
        },
      ),
    );
  }
}