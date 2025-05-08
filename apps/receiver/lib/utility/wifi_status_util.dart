import 'dart:async';

import 'package:flutter/services.dart';

import 'log.dart';

class WifiStatusUtil {
  static const MethodChannel _channel =
      MethodChannel('com.mvbcast.crosswalk/wifi_status');
  static const EventChannel _eventChannel =
      EventChannel('com.mvbcast.crosswalk/wifi_status_events');

  // 單例模式實現
  static final WifiStatusUtil _instance = WifiStatusUtil._internal();

  factory WifiStatusUtil() {
    return _instance;
  }

  WifiStatusUtil._internal();

  // 用於存儲 WiFi 狀態
  final _wifiStatusController = StreamController<bool>.broadcast();

  // 用於存儲事件訂閱
  StreamSubscription? _eventSubscription;

  // 初始化並開始監聽 WiFi 狀態變化
  void initialize() {
    // 取消之前的訂閱（如果有）
    _eventSubscription?.cancel();

    // 訂閱 WiFi 狀態變化事件
    _eventSubscription =
        _eventChannel.receiveBroadcastStream().listen((dynamic event) {
      // 發送事件
      _wifiStatusController.add(event as bool);
    }, onError: (dynamic error) {
      // 處理錯誤
      log.info('WifiStatusUtil WiFi status event error: $error');
    });
  }

  // 獲取 WiFi 狀態變化的流
  Stream<bool> get wifiStatusStream => _wifiStatusController.stream;

  // 檢查 WiFi 是否啟用
  static Future<bool> isWifiEnabled() async {
    final bool isEnabled = await _channel.invokeMethod('isWifiEnabled');
    return isEnabled;
  }

  // 釋放資源
  void dispose() {
    _eventSubscription?.cancel();
    _wifiStatusController.close();
  }
}
