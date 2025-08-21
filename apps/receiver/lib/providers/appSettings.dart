import 'dart:async';

import 'package:display_flutter/model/remote_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const _kUseMulticastKey = 'useMulticast';

  bool _useMulticast = false;
  bool _loaded = false;

  final Completer<void> _ready = Completer<void>();

  Future<void> get ready => _ready.future;

  bool get isLoaded => _loaded;

  bool get useMulticast => _useMulticast;

  RemoteScreenType get remoteScreenType =>
      _useMulticast ? RemoteScreenType.multicast : RemoteScreenType.rtc;

  AppSettings() {
    // 非同步初始化
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _useMulticast = prefs.getBool(_kUseMulticastKey) ?? false;
      _loaded = true;
      notifyListeners();
      _ready.complete();
    } catch (e, st) {
      _ready.completeError(e, st);
      rethrow;
    }
  }

  Future<void> setUseMulticast(bool value) async {
    if (_useMulticast == value) return;
    _useMulticast = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUseMulticastKey, value);
  }
}
