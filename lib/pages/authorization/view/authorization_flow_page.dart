import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/pages/authorization/bloc/authorization_bloc.dart';
import 'package:morzelingo/pages/authorization/repository/authorization_repository.dart';
import 'package:morzelingo/pages/authorization/service/authorization_service.dart';
import 'package:morzelingo/pages/authorization/view/login_page.dart';
import 'package:morzelingo/pages/authorization/view/register_page.dart';
import 'package:morzelingo/pages/loading_page.dart';

import '../../../app_theme.dart';

class AuthorizationFlowPage extends StatelessWidget {
  const AuthorizationFlowPage({super.key});


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthorizationBloc(repository: AuthorizationRepository(ApiClient()), service: AuthorizationService())..add(const CheckLoginedEvent()),
      child: BlocConsumer<AuthorizationBloc, AuthorizationState>(
        listener: (context, state) {
          if (state.status != AuthorizationStatus.idle) {
            Fluttertoast.showToast(
              msg: state.message.toString(),
              backgroundColor: state.status == AuthorizationStatus.success ? AppTheme.success : AppTheme.error,
              textColor: Colors.white
            );
          }
          if (state.status == AuthorizationStatus.success || state.status == AuthorizationStatus.sessionSuccess) {
            Navigator.pushReplacementNamed(context, "/home");
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingPage();
          } else {
            switch (state.mode) {
              case AuthorizationMode.login:
                return const LoginPage();
              case AuthorizationMode.register:
                return const RegisterPage();
            }
          }
        },
      ),
    );
  }
}
