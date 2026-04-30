import 'package:flutter/material.dart';

class AdRouteObserver extends NavigatorObserver with ChangeNotifier {
  AdRouteObserver({
    required Set<String> hiddenRoutes,
  }) : _hiddenRoutes = hiddenRoutes;

  final Set<String> _hiddenRoutes;

  bool _showBanner = false;

  bool get showBanner => _showBanner;

  void _update(Route<dynamic>? route) {
    final String? routeName = route?.settings.name;

    final bool nextValue = routeName != null && !_hiddenRoutes.contains(routeName);

    if (_showBanner == nextValue) return;

    _showBanner = nextValue;
    notifyListeners();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _update(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _update(previousRoute);
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    _update(newRoute);
  }
}