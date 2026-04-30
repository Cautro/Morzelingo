import 'dart:async';

import 'package:flutter/material.dart';

import 'interstitial_ad_service.dart';

class InterstitialAdCoordinator extends NavigatorObserver
    with WidgetsBindingObserver {
  InterstitialAdCoordinator({
    required Set<String> hiddenRoutes,
  }) : _hiddenRoutes = hiddenRoutes;

  final Set<String> _hiddenRoutes;

  Timer? _timer;

  String? _currentRouteName;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  void start() {
    WidgetsBinding.instance.addObserver(this);

    InterstitialAdService.instance.start();

    _timer = Timer.periodic(
      const Duration(seconds: 30),
          (_) => _tryShowByTimer(),
    );
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    InterstitialAdService.instance.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateRoute(route);
    _tryShowAfterRouteChange();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateRoute(previousRoute);
    _tryShowAfterRouteChange();
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    _updateRoute(newRoute);
    _tryShowAfterRouteChange();
  }

  void _updateRoute(Route<dynamic>? route) {
    _currentRouteName = route?.settings.name;
  }

  void _tryShowAfterRouteChange() {
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      unawaited(
        InterstitialAdService.instance.tryShow(
          placement: 'route_change:$_currentRouteName',
        ),
      );
    });
  }

  void _tryShowByTimer() {
    if (_lifecycleState != AppLifecycleState.resumed) return;
    if (!_isCurrentRouteAllowed) return;

    unawaited(
      InterstitialAdService.instance.tryShow(
        placement: 'timer:$_currentRouteName',
      ),
    );
  }

  bool get _isCurrentRouteAllowed {
    final String? routeName = _currentRouteName;

    if (routeName == null) return false;

    return !_hiddenRoutes.contains(routeName);
  }
}