import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/core/authorization/authorization.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/authorization/view/authorization_flow_page.dart';
import 'package:morzelingo/pages/duels/view/duels_main_page.dart';
import 'package:morzelingo/pages/freemode/view/freemode_flow_page.dart';
import 'package:morzelingo/pages/friends/view/friends_page.dart';
import 'package:morzelingo/pages/hints/view/hints_page.dart';
import 'package:morzelingo/pages/practice/presentation/view/practice_letters_page.dart';
import 'package:morzelingo/pages/profile/data/repositories/profile_repository.dart';
import 'package:morzelingo/pages/profile/presentation/view/profile_page.dart';
import 'package:morzelingo/pages/profile/presentation/view/settings_page.dart';
import 'package:morzelingo/theme_controller.dart';

import 'app_theme.dart';
import 'pages/home_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _handleGlobalError(details.exception, details.stack ?? StackTrace.empty);
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _handleGlobalError(error, stack);
      return true;
    };
    runApp(const MyApp());
  }, (Object error, StackTrace stack) {
    _handleGlobalError(error, stack);
  });
}

void _handleGlobalError(Object error, StackTrace stack) {
  if (error is UnauthorizedException) {
    unawaited(Authorization().deleteToken());
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
          (route) => false,
    );
    return;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: "/login",
          routes: {
            "/home": (context) => const HomeTabsPage(),
            "/login": (context) => const AuthorizationFlowPage(),
            "/freemode": (context) => const FreemodeFlowPage(),
            "/profile": (context) =>
                ProfilePage(repository: ProfileRepository(ApiClient())),
            "/practiceletter": (context) => const LettersFlowPage(),
            "/settings": (context) => const SettingsPage(),
            "/friends": (context) => const FriendsPage(),
            "/duels": (context) => const DuelsMainPage(),
            "/hints": (context) => const HintsPage(),
          },
        );
      },
    );
  }
}