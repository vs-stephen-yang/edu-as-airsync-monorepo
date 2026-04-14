import 'package:flutter/material.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

extension NavigationServiceExtension on NavigationService {
  static final List<DialogRoute<dynamic>> _dialogRoutes = [];

  void setRoute(DialogRoute<dynamic> route) {
    _dialogRoutes.add(route);
  }

  void dismissRegisteredDialogs() {
    for (var route in _dialogRoutes) {
      if (route.navigator == null) {
        continue;
      }

      if (route.navigator!.canPop()) {
        route.navigator!.pop();
        route.navigator!.removeRoute(route);
      }
    }

    _dialogRoutes.clear();
  }
}
