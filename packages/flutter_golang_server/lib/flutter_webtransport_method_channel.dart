import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_webtransport_config.dart';
import 'flutter_webtransport_listener.dart';
import 'flutter_webtransport_platform_interface.dart';

/// An implementation of [FlutterWebtransportPlatform] that uses method channels.
class MethodChannelFlutterWebtransport extends FlutterWebtransportPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_golang_server');
  FlutterWebtransportListener? _listener;

  MethodChannelFlutterWebtransport() {
    // Register the handler for the method calls from the native side
    methodChannel.setMethodCallHandler(onMethodCallFromNative);
  }

  @override
  Future<void> startWebTransportServer(FlutterWebtransportConfig config) async {
    try {
      await methodChannel
          .invokeMethod('startWebTransportServer', <String, dynamic>{
        'configuration': config.toMap(),
      });
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> stopServer() async {
    await methodChannel.invokeMethod('stopWebTransportServer');
  }

  @override
  Future<void> sendMessage(String connId, String message) async {
    await methodChannel.invokeMethod("sendWebTransportMessage",
        <String, String>{'connId': connId, 'message': message});
  }

  @override
  Future<void> updateCertificate(FlutterWebtransportConfig config) async {
    await methodChannel.invokeMethod("updateWebTransportCertificate", <String, dynamic>{
      'configuration': config.toMap(),
    });
  }

  @override
  void registerListener(FlutterWebtransportListener listener) {
    _listener = listener;
  }

  Future<dynamic> onMethodCallFromNative(MethodCall call) async {
    try {
      print("onMethodCallFromNative: ${call.method}");
      switch (call.method) {
        case 'onMessage':
          _listener?.onMessage(
            call.arguments['connId'],
            call.arguments['message'],
          );
          break;
        case 'onClose':
          _listener?.onClose(
            call.arguments['connId'],
          );
          break;
        case 'onConnect':
          _listener?.onConnect(
            call.arguments['connId'],
            call.arguments['queryStr'],
          );
          break;
        default:
          throw MissingPluginException();
      }
    } catch (e) {
      print("Malformed method call from native: ${call.method}. $e");
    }
  }
}
