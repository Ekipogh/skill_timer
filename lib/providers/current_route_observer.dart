import 'package:flutter/material.dart';

class CurrentRouteObserver extends NavigatorObserver with ChangeNotifier {
  String _currentRoute = '/';

  String get currentRoute => _currentRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _updateCurrentRoute(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _updateCurrentRoute(previousRoute);
    }
  }

  void _updateCurrentRoute(Route route) {
    if (route.settings.name != null) {
      _currentRoute = route.settings.name!;
      notifyListeners();
    }
  }
}