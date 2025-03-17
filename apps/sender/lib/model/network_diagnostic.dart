import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:display_channel/display_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:display_cast_flutter/utilities/log.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TestResult {
  final bool success;
  final String? error;

  TestResult({
    required this.success,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error': error,
    };
  }
}

class PortTestResult extends TestResult {
  final int port;
  final String protocol;

  PortTestResult({
    required this.port,
    required this.protocol,
    required super.success,
    super.error,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['port'] = port;
    json['protocol'] = protocol;
    return json;
  }
}

class WebSocketTestResult extends TestResult {
  final String url;

  WebSocketTestResult({
    required this.url,
    required super.success,
    super.error,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['url'] = url;
    return json;
  }
}

class NetworkDiagnostic {
  final DiagnosticResults _results = DiagnosticResults();

  NetworkDiagnostic();

  // Run all diagnostic tests
  Future<DiagnosticResults> runAllTests(String receiverIp, int port) async {
    if (kIsWeb) {
      // Web platform has different network behavior, skip tests
      return _results;
    }

    // Test TCP connection
    await _testTcpConnection(receiverIp, port);

    // Test WebSocket connection
    await _testWebSocketConnection(receiverIp, port);

    _results.logResult();
    return _results;
  }

  // Test TCP connection to the receiver
  Future<void> _testTcpConnection(String ip, int port,
      {int timeout = 5}) async {
    try {
      log.info('[Network Diagnostic] Testing TCP connection to $ip:$port...');
      final socket =
          await Socket.connect(ip, port, timeout: Duration(seconds: timeout));
      log.info('[Network Diagnostic] Successfully connected to $ip:$port');
      await socket.close();
      _results.portTests
          .add(PortTestResult(port: port, protocol: 'tcp', success: true));
    } on SocketException catch (e) {
      log.info(
          '[Network Diagnostic] Failed to connect to $ip:$port: ${e.message}');
      _results.portTests.add(PortTestResult(
          port: port, protocol: 'tcp', success: false, error: e.toString()));
    } catch (e) {
      log.info('[Network Diagnostic] Error while connecting to $ip:$port: $e');
      _results.portTests.add(PortTestResult(
          port: port, protocol: 'tcp', success: false, error: e.toString()));
    }
  }

  // Test WebSocket connection and get ice server list
  Future<void> _testWebSocketConnection(String ip, int port,
      {int timeout = 10}) async {
    final wsUrl = 'wss://$ip:$port';
    WebSocket? wsClient;

    try {
      log.info(
          '[Network Diagnostic] Testing WebSocket connection to $wsUrl...');

      // Create a completer to handle timeout
      final completer = Completer<WebSocketTestResult>();

      // Set timeout
      Timer(Duration(seconds: timeout), () {
        if (!completer.isCompleted) {
          completer.complete(WebSocketTestResult(
            url: wsUrl,
            success: false,
            error: 'Connection timeout after $timeout seconds',
          ));
        }
      });

      // Connect to WebSocket
      final httpClient = HttpClient();

      // Determine whether to allow self-signed certificates.
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      wsClient = await WebSocket.connect(wsUrl, customClient: httpClient);

      wsClient.listen((dynamic data) {
        if (!completer.isCompleted) {
          log.info('[Network Diagnostic] WebSocket connected');
          completer.complete(WebSocketTestResult(
            url: wsUrl,
            success: true,
          ));
        }
      }, onDone: () {
        if (!completer.isCompleted) {
          log.info(
              '[Network Diagnostic] WebSocket connection closed without receiving data');
          completer.complete(WebSocketTestResult(
            url: wsUrl,
            success: false,
            error: 'Connection closed without receiving data',
          ));
        }
      }, onError: (error) {
        if (!completer.isCompleted) {
          log.info('[Network Diagnostic] WebSocket connection error: $error');
          completer.complete(WebSocketTestResult(
            url: wsUrl,
            success: false,
            error: error.toString(),
          ));
        }
      });

      _results.webSocketTest = await completer.future;
    } catch (e) {
      log.info('[Network Diagnostic] Failed to connect to WebSocket: $e');
      _results.webSocketTest = WebSocketTestResult(
        url: wsUrl,
        success: false,
        error: e.toString(),
      );
    } finally {
      await wsClient?.close();
    }
  }
}

// Models for diagnostic results and configuration
class DiagnosticResults {
  List<PortTestResult> portTests = [];
  WebSocketTestResult? webSocketTest;

  Map<String, dynamic> toJson() {
    return {
      'portTests': portTests.map((test) => test.toJson()).toList(),
      'webSocketTest': webSocketTest?.toJson(),
    };
  }

  logResult() {
    String jsonString = jsonEncode(toJson());
    log.info('[Network Diagnostic] Result: $jsonString');
  }
}
