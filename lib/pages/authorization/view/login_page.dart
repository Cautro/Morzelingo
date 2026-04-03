import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ui/app_ui.dart';
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
            padding: AppSpacing.page,
            child: AppFormShell(
              icon: Icons.login_rounded,
              title: 'Вход',
              subtitle: 'Продолжите обучение азбуке Морзе.',
              footer: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    context.read<AuthorizationBloc>().add(ChangeModeEvent());
                  },
                  child: const Text('Нет аккаунта? Зарегистрироваться'),
                ),
              ),
              children: [
                TextField(
                  onChanged: (value) => login = value,
                  decoration: const InputDecoration(
                    labelText: 'Имя пользователя',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  onChanged: (value) => password = value,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  onPressed: () {
                    context.read<AuthorizationBloc>().add(
                          LoginEvent(login: login, password: password),
                        );
                  },
                  child: const Text('Войти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
