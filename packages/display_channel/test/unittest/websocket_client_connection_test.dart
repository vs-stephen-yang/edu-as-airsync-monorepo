import 'dart:io';
import 'dart:convert';
import 'package:display_channel/display_channel.dart';
import 'package:flutter_test/flutter_test.dart';

class ControllableWebSocketServer {
  HttpServer? _server;
  int? _port;
  final List<WebSocket> _clients = [];

  Future<void> start() async {
    _server = await HttpServer.bind('localhost', 0);
    _port = _server!.port;

    _server!.transform(WebSocketTransformer()).listen((WebSocket webSocket) {
      _clients.add(webSocket);
      print('Server: Client connected');

      webSocket.listen(
        (data) {
          try {
            final message = jsonDecode(data);
            print('Server received: $message');

            // Echo back with timestamp
            webSocket.add(jsonEncode({
              'type': 'echo',
              'original': message,
              'serverTime': DateTime.now().millisecondsSinceEpoch,
            }));
          } catch (e) {
            print('Server parse error: $e');
          }
        },
        onDone: () {
          print('Server: Client disconnected');
          _clients.remove(webSocket);
        },
        onError: (error) {
          print('Server error: $error');
          _clients.remove(webSocket);
        },
      );
    });
  }

  String get url => 'ws://localhost:$_port';

  Future<void> disconnectAllClients() async {
    print('Server: Gracefully disconnecting all clients');
    final clientsToClose = List.from(_clients);
    for (var client in clientsToClose) {
      try {
        await client.close(1000, 'Server initiated disconnect');
      } catch (e) {
        print('Server close error: $e');
      }
    }
    _clients.clear();
  }

  int get clientCount => _clients.length;

  Future<void> stop() async {
    await disconnectAllClients();
    await _server?.close();
  }
}

void main() {
  group('WebSocket Healthy Behavior Tests', () {
    late ControllableWebSocketServer server;
    late WebSocketClientConnectionConfig config;

    setUp(() async {
      server = ControllableWebSocketServer();
      await server.start();

      config = WebSocketClientConnectionConfig(
        connectionTimeout: const Duration(seconds: 2),
        retry: const RetryConfig(
            maxRetryAttempts: 5, maxRetryDelay: Duration(milliseconds: 300)),
        pingInterval: const Duration(seconds: 1),
        allowSelfSignedCertificates: true,
        logger: (url, message) {
          print('CLIENT: $message');
        },
      );
    });

    tearDown(() async {
      await server.stop();
    });

    test('Normal connection lifecycle works correctly', () async {
      final connection = WebSocketClientConnection(server.url, config);

      bool connected = false;
      List<Map<String, dynamic>> receivedMessages = [];

      connection.onConnected = () {
        connected = true;
        print('✅ Connected successfully');
      };

      connection.onDisconnected = () {
        print('📴 Disconnected');
      };

      connection.onMessage = (data) {
        receivedMessages.add(data);
        print('📨 Received: $data');
      };

      connection.open();
      await Future.delayed(const Duration(seconds: 1));

      expect(connected, isTrue, reason: 'Should connect successfully');
      expect(server.clientCount, equals(1),
          reason: 'Server should have 1 client');

      connection.send({
        'test': 'hello',
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });
      await Future.delayed(const Duration(milliseconds: 500));

      expect(receivedMessages.length, equals(1),
          reason: 'Should receive echo message');
      expect(receivedMessages[0]['type'], equals('echo'));
      expect(receivedMessages[0]['original']['test'], equals('hello'));

      connection.close();
      await Future.delayed(const Duration(milliseconds: 500));

      expect(server.clientCount, equals(0),
          reason: 'Server should have no clients');
    });

    test('Reconnection after server disconnect works properly', () async {
      final connection = WebSocketClientConnection(server.url, config);

      int connectCount = 0;
      int disconnectCount = 0;
      List<String> connectionStates = [];

      connection.onConnected = () {
        connectCount++;
        connectionStates.add('connected_$connectCount');
        print('✅ Connected #$connectCount');
      };

      connection.onDisconnected = () {
        disconnectCount++;
        connectionStates.add('disconnected_$disconnectCount');
        print('📴 Disconnected #$disconnectCount');
      };

      connection.onConnectFailed = (error) {
        connectionStates.add('failed_${error.message}');
        print('❌ Connect failed: ${error.message}');
      };

      connection.open();
      await Future.delayed(const Duration(seconds: 1));

      expect(connectCount, equals(1));
      expect(server.clientCount, equals(1));

      await server.disconnectAllClients();
      await Future.delayed(const Duration(milliseconds: 800)); // 等待重連

      expect(disconnectCount, equals(1), reason: 'Should detect disconnection');
      expect(connectCount, equals(2), reason: 'Should reconnect automatically');
      expect(server.clientCount, equals(1), reason: 'Should have reconnected');

      connection.send({'test': 'after_reconnect'});
      await Future.delayed(const Duration(milliseconds: 300));

      print('Connection states: $connectionStates');

      connection.close();
    });

    test('Multiple open() calls should not create duplicate connections',
        () async {
      final connection = WebSocketClientConnection(server.url, config);

      int connectCount = 0;
      connection.onConnected = () {
        connectCount++;
      };

      connection.open();
      connection.open();
      connection.open();

      await Future.delayed(const Duration(seconds: 1));

      expect(connectCount, equals(1),
          reason: 'Should only connect once despite multiple open() calls');
      expect(server.clientCount, equals(1),
          reason: 'Server should only see one connection');

      connection.close();
    });

    test('Connection can be reopened after close', () async {
      final connection = WebSocketClientConnection(server.url, config);

      int connectCount = 0;
      connection.onConnected = () {
        connectCount++;
      };

      connection.open();
      await Future.delayed(const Duration(seconds: 1));
      expect(connectCount, equals(1));

      connection.close();
      await Future.delayed(const Duration(milliseconds: 300));
      expect(server.clientCount, equals(0));

      connection.open();
      await Future.delayed(const Duration(seconds: 1));
      expect(connectCount, equals(2),
          reason: 'Should be able to reconnect after close');
      expect(server.clientCount, equals(1));

      connection.close();
    });

    test('Message sending during unstable connection handles gracefully',
        () async {
      List<String> logs = [];
      final testConfig = WebSocketClientConnectionConfig(
        connectionTimeout: config.connectionTimeout,
        retry: config.retry,
        pingInterval: config.pingInterval,
        allowSelfSignedCertificates: config.allowSelfSignedCertificates,
        logger: (url, message) {
          logs.add(message);
          print('LOG: $message');
        },
      );

      final connection = WebSocketClientConnection(server.url, testConfig);

      int messagesReceived = 0;
      connection.onMessage = (data) {
        messagesReceived++;
      };

      connection.open();
      await Future.delayed(const Duration(seconds: 1));

      for (int i = 0; i < 3; i++) {
        connection.send({'stable': i});
      }
      await Future.delayed(const Duration(milliseconds: 300));

      int stableMessages = messagesReceived;
      print('Messages received in stable state: $stableMessages');

      await server.disconnectAllClients();

      for (int i = 0; i < 3; i++) {
        connection.send({'during_reconnect': i});
        await Future.delayed(const Duration(milliseconds: 100));
      }

      await Future.delayed(const Duration(seconds: 2));

      for (int i = 0; i < 3; i++) {
        connection.send({'after_reconnect': i});
      }
      await Future.delayed(const Duration(milliseconds: 500));

      print('Total messages received: $messagesReceived');

      final errorLogs = logs
          .where((log) =>
              log.contains('Reading from a closed socket') ||
              log.contains('Bad state') ||
              log.toLowerCase().contains('exception'))
          .toList();

      print('Error logs: $errorLogs');

      expect(errorLogs.isEmpty, isTrue,
          reason: 'Should not have critical errors');
      expect(messagesReceived, greaterThan(stableMessages),
          reason: 'Should receive messages after reconnection');

      connection.close();
    });

    test('Resource cleanup verification', () async {
      final connection = WebSocketClientConnection(server.url, config);

      for (int cycle = 0; cycle < 3; cycle++) {
        print('\n--- Cycle $cycle ---');

        connection.open();
        await Future.delayed(const Duration(milliseconds: 500));
        expect(server.clientCount, equals(1),
            reason: 'Should connect in cycle $cycle');

        connection.send({'cycle': cycle, 'message': 'test'});
        await Future.delayed(const Duration(milliseconds: 200));

        connection.close();
        await Future.delayed(const Duration(milliseconds: 300));
        expect(server.clientCount, equals(0),
            reason: 'Should disconnect cleanly in cycle $cycle');
      }

      print('✅ Resource cleanup test completed successfully');
    });
  });
}
