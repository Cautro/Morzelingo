import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morzelingo/pages/authorization/bloc/authorization_bloc.dart';
import 'package:morzelingo/pages/authorization/repository/authorization_repository.dart';
import 'package:morzelingo/pages/authorization/service/authorization_service.dart';
import 'package:morzelingo/pages/authorization/view/login_page.dart';
import 'package:morzelingo/pages/authorization/view/register_page.dart';

import '../../../app_theme.dart';

class AuthorizationFlowPage extends StatelessWidget {
  const AuthorizationFlowPage({super.key});


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthorizationBloc(repository: AuthorizationRepository(), service: AuthorizationService())..add(CheckLoginedEvent()),
      child: BlocConsumer<AuthorizationBloc, AuthorizationState>(
        listener: (context, state) {
          print('cheeeeeeck');
          if (state.status != AuthorizationStatus.idle) {
            Fluttertoast.showToast(
              msg: state.message.toString(),
              backgroundColor: state.status == AuthorizationStatus.success ? AppTheme.success : AppTheme.error,
              textColor: Colors.white
            );
          }
          if (state.status == AuthorizationStatus.success) {
            Navigator.pushReplacementNamed(context, "/home");
          }
        },
        builder: (context, state) {
          switch (state.mode) {
            case AuthorizationMode.login:
              return LoginPage();
            case AuthorizationMode.register:
              return RegisterPage();
          }
        },
      ),
    );
  }
}
