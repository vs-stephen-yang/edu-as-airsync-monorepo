import 'package:flutter_test/flutter_test.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/client_connection.dart';

/// Helper to process pending microtasks
Future<void> pumpEventQueue() => Future.delayed(Duration.zero);

class MockClientConnection implements ClientConnection {
  bool openCalled = false;
  bool closeCalled = false;

  @override
  void Function()? onConnecting;
  @override
  void Function(ConnectError error)? onConnectFailed;
  @override
  void Function()? onConnected;
  @override
  void Function()? onDisconnected;
  @override
  void Function(Map<String, dynamic> message)? onMessage;

  @override
  void open() {
    openCalled = true;
    onConnecting?.call();
  }

  @override
  void close() {
    closeCalled = true;
  }

  @override
  void send(Map<String, dynamic> message) {}

  void simulateConnected() {
    onConnected?.call();
  }

  Future<void> simulateConnectionFailed(ConnectErrorType error) async {
    onConnectFailed?.call(ConnectError(error, ''));
    await pumpEventQueue();
  }

  void simulateChannelConnected() {
    onMessage?.call(
      ChannelConnectedMessage(100, 100, 'abc', 1).toJson(),
    );
  }

  Future<void> simulateSuccessfulConnection() async {
    simulateConnected();
    simulateChannelConnected();

    await pumpEventQueue();
  }
}

void main() {
  late List<MockClientConnection> directConnections;
  late MockClientConnection tunnelConnection;
  late List<Channel> openedChannels;
  late List<ChannelConnectorError> errors;
  late DisplayChannelConnector connector;

  setUp(() {
    directConnections = [];
    tunnelConnection = MockClientConnection();
    openedChannels = [];
    errors = [];
  });

  DisplayChannelConnector createConnector({
    List<String> remoteIps = const ['192.168.1.1', '10.0.0.1'],
    int? instanceIndex,
  }) {
    return DisplayChannelConnector(
      clientId: 'test-client',
      otp: '1234',
      displayCode: DisplayCode(
        instanceGroupId: 1,
        instanceIndex: instanceIndex,
      ),
      remoteIpAddresses: remoteIps,
      encodedDisplayCode: 'test-code',
      createConnectionDirect: (url, isReconnect) {
        final conn = MockClientConnection();
        directConnections.add(conn);
        return conn;
      },
      createConnectionTunnel: (_, __) {
        tunnelConnection = MockClientConnection();
        return tunnelConnection;
      },
      fetchTunnelUrl: (_, __) => Future.value('ws://test'),
      onOpened: (channel, isDirect) => openedChannels.add(channel),
      onOpenError: (error) => errors.add(error),
    );
  }

  group('Direct Connections', () {
    test('attempts connections to all remote IPs', () async {
      // Arrange
      connector = createConnector();

      // Act
      connector.open(directPort: 8080);
      await pumpEventQueue();

      // Assert
      expect(directConnections.length, equals(2));
      expect(directConnections.every((c) => c.openCalled), isTrue);
    });

    test('succeeds with first successful connection', () async {
      // Arrange
      connector = createConnector();
      connector.open(directPort: 8080);
      await pumpEventQueue();

      // Act
      await directConnections.first.simulateSuccessfulConnection();

      // Assert
      expect(openedChannels.length, equals(1));
      expect(directConnections.last.closeCalled, isTrue);
    });

    test('continues after first connection fails', () async {
      // Arrange
      connector = createConnector();

      // Act
      connector.open(directPort: 8080);
      await pumpEventQueue();

      await directConnections.first
          .simulateConnectionFailed(ConnectErrorType.socket);

      // Assert
      expect(errors, isEmpty);
      expect(directConnections.last.closeCalled, isFalse);
    });

    test('reports error when all connections fail', () async {
      connector = createConnector();

      connector.open(directPort: 8080);
      await pumpEventQueue();

      for (final conn in directConnections) {
        await conn.simulateConnectionFailed(ConnectErrorType.socket);
      }

      expect(errors.length, equals(1));
      expect(errors.first, equals(ChannelConnectorError.networkError));
    });
  });

  group('Tunnel Connection', () {
    test('attempts tunnel when instance index available', () async {
      // Arrange
      connector = createConnector(instanceIndex: 1, remoteIps: []);

      // Act
      connector.open();
      await pumpEventQueue();

      // Assert
      expect(tunnelConnection.openCalled, isTrue);
    });

    test('succeeds with tunnel connection', () async {
      // Arrange
      connector = createConnector(instanceIndex: 1, remoteIps: []);

      // Act
      connector.open();
      await pumpEventQueue();

      await tunnelConnection.simulateSuccessfulConnection();

      // Assert
      expect(openedChannels.length, equals(1));
    });
  });

  group('Dual Mode', () {
    test('direct wins race', () async {
      // Arrange
      connector = createConnector(instanceIndex: 1);

      // Act
      connector.open(directPort: 8080);
      await pumpEventQueue();

      await directConnections.first.simulateSuccessfulConnection();

      // Assert
      expect(openedChannels.length, equals(1));
      expect(tunnelConnection.closeCalled, isTrue);
    });

    test('tunnel wins race', () async {
      // Arrange
      connector = createConnector(instanceIndex: 1);

      // Act
      connector.open(directPort: 8080);
      await pumpEventQueue();

      await tunnelConnection.simulateSuccessfulConnection();

      // Assert
      expect(openedChannels.length, equals(1));
      expect(directConnections.every((c) => c.closeCalled), isTrue);
    });
  });

  group('Dual Mode - Race Conditions', () {
    test('direct wins even if tunnel succeeds later', () async {
      // Arrange
      connector = createConnector(instanceIndex: 1);
      connector.open(directPort: 8080);
      await pumpEventQueue();

      // Act - Direct connects first
      await directConnections.first.simulateSuccessfulConnection();

      // Tunnel connects after
      await tunnelConnection.simulateSuccessfulConnection();

      // Assert
      expect(openedChannels.length, equals(1)); // Only one connection accepted
      expect(tunnelConnection.closeCalled, isTrue); // Tunnel was closed
      expect(directConnections.first.closeCalled, isFalse); // Winner stays open
    });

    test('tunnel wins even if direct succeeds later', () async {
      // Arrange
      connector = createConnector(instanceIndex: 1);

      // Act
      connector.open(directPort: 8080);
      await pumpEventQueue();

      // Act - Tunnel connects first
      await tunnelConnection.simulateSuccessfulConnection();

      // Direct connects after
      await directConnections.first.simulateSuccessfulConnection();

      // Assert
      expect(openedChannels.length, equals(1)); // Only one connection accepted
      expect(tunnelConnection.closeCalled, isFalse); // Winner stays open
      // All direct connections closed
      expect(directConnections.every((c) => c.closeCalled), isTrue);
    });
  });

  group('Cleanup', () {
    test('cleans up resources when direct connection succeeds', () async {
      // Arrange
      connector = createConnector(
          remoteIps: ['192.168.1.1', '10.0.0.1'], instanceIndex: 1);

      // Act
      connector.open(directPort: 8080);
      await pumpEventQueue();

      await directConnections.first.simulateSuccessfulConnection();

      // Assert
      expect(directConnections[1].closeCalled, isTrue);
      expect(tunnelConnection.closeCalled, isTrue);
    });

    test('cleans up resources when tunnel connection succeeds', () async {
      // Arrange
      connector = createConnector(instanceIndex: 1);

      // Act
      connector.open(directPort: 8080);
      await pumpEventQueue();

      await tunnelConnection.simulateSuccessfulConnection();

      // Assert
      expect(directConnections.every((c) => c.closeCalled), isTrue);
    });
  });
}
