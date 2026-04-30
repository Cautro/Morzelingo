import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:morzelingo/core/ads/interstitial_ad_coordinator.dart';
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
import 'package:yandex_mobileads/mobile_ads.dart';

import 'app_theme.dart';
import 'pages/home_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final InterstitialAdCoordinator interstitialAdCoordinator =
InterstitialAdCoordinator(
  hiddenRoutes: {
    '/login',
    '/freemode',
    '/practiceletter',
    '/duels',
  },
);

Future<void> main() async {
  runZonedGuarded<Future<void>>(
        () async {
      WidgetsFlutterBinding.ensureInitialized();

      _setupGlobalErrorHandling();

      runApp(const MyApp());

      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_safeInitializeAds());
      });
    },
        (Object error, StackTrace stack) {
      _handleGlobalError(error, stack);
    },
  );
}

void _setupGlobalErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _handleGlobalError(
      details.exception,
      details.stack ?? StackTrace.empty,
    );
  };

  PlatformDispatcher.instance.onError = (
      Object error,
      StackTrace stack,
      ) {
    _handleGlobalError(error, stack);
    return true;
  };
}

Future<void> _safeInitializeAds() async {
  try {
    await YandexAds.setLogging(kDebugMode);
    await YandexAds.setDebugErrorIndicator(kDebugMode);
    await YandexAds.initialize();

    interstitialAdCoordinator.start();
  } catch (error, stack) {
    _logError('Yandex Ads initialization failed', error, stack);

    // Важно:
    // если реклама не инициализировалась — приложение всё равно работает.
  }
}

void _handleGlobalError(Object error, StackTrace stack) {
  _logError('Global app error', error, stack);

  if (error is UnauthorizedException) {
    unawaited(Authorization().deleteToken());

    final navigator = navigatorKey.currentState;

    if (navigator != null) {
      navigator.pushNamedAndRemoveUntil(
        '/login',
            (route) => false,
      );
    }

    return;
  }

  // Остальные ошибки намеренно не пробрасываем дальше,
  // чтобы приложение не падало из-за второстепенных runtime-ошибок.
}

void _logError(String message, Object error, StackTrace stack) {
  if (kDebugMode) {
    debugPrint('[$message]');
    debugPrint(error.toString());
    debugPrintStack(stackTrace: stack);
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
          navigatorObservers: [
            interstitialAdCoordinator,
          ],
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: '/login',
          routes: {
            '/home': (context) => const HomeTabsPage(),
            '/login': (context) => const AuthorizationFlowPage(),
            '/freemode': (context) => const FreemodeFlowPage(),
            '/profile': (context) => ProfilePage(
              repository: ProfileRepository(ApiClient()),
            ),
            '/practiceletter': (context) => const LettersFlowPage(),
            '/settings': (context) => const SettingsPage(),
            '/friends': (context) => const FriendsPage(),
            '/duels': (context) => const DuelsMainPage(),
            '/hints': (context) => const HintsPage(),
          },
        );
      },
    );
  }
}