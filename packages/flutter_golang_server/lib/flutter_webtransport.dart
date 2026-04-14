import 'dart:async';

import 'package:cron/cron.dart';

import 'flutter_webtransport_config.dart';
import 'flutter_webtransport_listener.dart';
import 'flutter_webtransport_platform_interface.dart';

class FlutterWebtransport {
  FlutterWebtransportListener? _listener;
  Cron? _cron;

  void registerListener(FlutterWebtransportListener listener) {
    _listener = listener;
    return FlutterWebtransportPlatform.instance.registerListener(listener);
  }

  Future<void> startWebtransportServer(FlutterWebtransportConfig config) {
    scheduleTask();
    return FlutterWebtransportPlatform.instance.startWebTransportServer(config);
  }

  Future<void> stopServer() {
    _cron?.close(); // Stop the cron job when stopping the server
    _cron = null;

    return FlutterWebtransportPlatform.instance.stopServer();
  }

  Future<void> sendMessage(String connId, String message) {
    return FlutterWebtransportPlatform.instance.sendMessage(connId, message);
  }

  Future<void> closeWebTransportConn(String connId) {
    return FlutterWebtransportPlatform.instance.closeWebTransportConn(connId);
  }

  Future<void> updateCertificate(FlutterWebtransportConfig config) {
    return FlutterWebtransportPlatform.instance.updateCertificate(config);
  }

  void scheduleTask() {
    _cron?.close(); // Ensure any previous cron job is stopped before starting a new one
    _cron = Cron();

    Duration offset = DateTime.now().timeZoneOffset;

    int checkCertificateValidHour = 0;
    int checkCertificateValidLocalHour = checkCertificateValidHour + offset.inHours;

    // Runs every day at midnight (00:00)
    _cron?.schedule(Schedule.parse('0 $checkCertificateValidLocalHour * * *'), () async {
      _listener?.onRequestCertificate();
    });

    print("Cron job started");
  }
}
