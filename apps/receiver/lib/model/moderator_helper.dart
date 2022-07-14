import 'package:flutter/material.dart';

class ModeratorHelper with ChangeNotifier {
  static final ModeratorHelper _instance = ModeratorHelper.internal();

  static ModeratorHelper getInstance() {
    return _instance;
  }

  ModeratorHelper.internal();

  void refresh() {
    notifyListeners();
  }
}
