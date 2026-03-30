import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
                      child: Padding(
                        padding: const EdgeInsetsGeometry.all(24),
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (value) => login = value,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                  labelText: "Имя пользователя"
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              onChanged: (value) => password = value,
                              obscureText: true,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                  labelText: "Пароль"
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: () {
                                    print("logi $login");
                                    context.read<AuthorizationBloc>().add(
                                      LoginEvent(login: login, password: password),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                                  child: const Text("Войти", style: TextStyle(),)
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                                onPressed: () {
                                  context.read<AuthorizationBloc>().add(ChangeModeEvent());
                                },
                                child: const Text("Нет аккаунта? Зарегистрироваться")
                            )
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