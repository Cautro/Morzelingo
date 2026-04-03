import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ui/app_ui.dart';
import '../bloc/authorization_bloc.dart';

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
  String code = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.page,
            child: AppFormShell(
              icon: Icons.person_add_alt_1_rounded,
              title: 'Регистрация',
              subtitle: 'Создайте аккаунт, для доступа к обучению морзе.',
              footer: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    context.read<AuthorizationBloc>().add(ChangeModeEvent());
                  },
                  child: const Text('Уже есть аккаунт? Войти'),
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
                  onChanged: (value) => email = value,
                  decoration: const InputDecoration(
                    labelText: 'Email',
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
                const SizedBox(height: AppSpacing.md),
                TextField(
                  onChanged: (value) => confirmpassword = value,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Подтвердите пароль',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  onChanged: (value) => code = value,
                  decoration: const InputDecoration(
                    labelText: 'Код друга (если есть)',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  onPressed: () {
                    context.read<AuthorizationBloc>().add(
                          RegisterEvent(
                            login: login,
                            password: password,
                            confirmpassword: confirmpassword,
                            code: code,
                            email: email,
                          ),
                        );
                  },
                  child: const Text('Зарегистрироваться'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
