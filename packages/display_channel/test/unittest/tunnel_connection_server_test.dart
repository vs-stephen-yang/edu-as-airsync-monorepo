import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/channel_store.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/messages/channel_message.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:display_channel/src/server/tunnel/tunnel_connection_server.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message_handler.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message_parser.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeClientConnection extends ClientConnection
    implements TunnelMessageHandler {
  bool isCloseCalled = false;
  bool isOpenCalled = false;

  late TunnelMessageParser _messageParser;
  final sentTunnelMessages = <TunnelMessage>[];
  final sentClientMessages = <ChannelMessage>[];

  FakeClientConnection() {
    _messageParser = TunnelMessageParser(this);
  }
  @override
  void open() {
    isOpenCalled = true;
  }

  @override
  Future<void> close() {
    isCloseCalled = true;
    return Future<void>.value();
  }

  @override
  void send(Map<String, dynamic> message) {
    _messageParser.parse(message);
  }

  @override
  void onClientConnected(TunnelClientConnected msg) =>
      sentTunnelMessages.add(msg);

  @override
  void onClientDisconnected(TunnelClientDisconnected msg) =>
      sentTunnelMessages.add(msg);

  @override
  void onClientMsg(TunnelClientMsg msg) {
    final clientMsg = ChannelMessage.parse(msg.data);
    sentClientMessages.add(clientMsg!);
  }

  @override
  void onDisconnectClient(TunnelDisconnectClient msg) =>
      sentTunnelMessages.add(msg);

  @override
  void onHeartbeat(TunnelHeartbeatMessage msg) => sentTunnelMessages.add(msg);
}

void main() {
  late TunnelConnectionServer server;
  late FakeClientConnection tunnelConnection;
  late ConnectRequestStatus connectRequestStatus;

  late bool onTunnelConnectedCalled;
  late bool onTunnelConnectingCalled;
  late int createTunnelConnectionCalledCount;
  late List<Connection> connections;

  injectTunnelConnectedMessage() {
    final message = TunnelClientConnected(
      '10000',
      '100',
      '4444',
      'DEF',
    );

    tunnelConnection.onMessage?.call(message.toJson());
  }

  setUp(() {
    connections = <Connection>[];

    tunnelConnection = FakeClientConnection();

    server = TunnelConnectionServer(
      () {
        createTunnelConnectionCalledCount += 1;
        return tunnelConnection;
      },
      (String clientId, Connection connection) => connections.add(connection),
      (ConnectionRequest connectRequest) => connectRequestStatus,
      heartbeatInterval: const Duration(minutes: 5),
      idleConnectionTimeout: const Duration(seconds: 10),
    );

    onTunnelConnectedCalled = false;
    onTunnelConnectingCalled = false;
    createTunnelConnectionCalledCount = 0;

    connectRequestStatus = ConnectRequestStatus.success;

    server.onTunnelConnected = () {
      onTunnelConnectedCalled = true;
    };

    server.onTunnelConnecting = () {
      onTunnelConnectingCalled = true;
    };
  });

  test('start should open the connection', () async {
    // arrange

    // action
    server.start();

    // assert
    expect(tunnelConnection.isOpenCalled, true);
  });

  test('heartbeat should start when the tunnel connection is connected',
      () async {
    // arrange
    server.start();

    fakeAsync((async) {
      // action
      tunnelConnection.onConnected?.call();

      async.elapse(const Duration(minutes: 10));

      // assert
      expect(tunnelConnection.sentTunnelMessages.length, 2);

      expect(tunnelConnection.sentTunnelMessages[0],
          isA<TunnelHeartbeatMessage>());
      expect(tunnelConnection.sentTunnelMessages[1],
          isA<TunnelHeartbeatMessage>());
    });
  });

  test('heartbeat should stop when the server is closed', () async {
    // arrange
    server.start();

    fakeAsync((async) {
      // action
      tunnelConnection.onConnected?.call();
      async.elapse(const Duration(minutes: 6));

      server.stop();
      async.elapse(const Duration(minutes: 100));

      // assert
      expect(tunnelConnection.sentTunnelMessages.length, 1);
      expect(tunnelConnection.sentTunnelMessages[0],
          isA<TunnelHeartbeatMessage>());
    });
  });

  test('A new connection should be notified for a valid request', () async {
    // arrange
    server.start();
    tunnelConnection.onConnected?.call();
    connectRequestStatus = ConnectRequestStatus.success;

    // action
    injectTunnelConnectedMessage();

    // assert
    expect(connections.length, 1);
  });

  test('channel-closed should be sent if the token is invalid', () async {
    // arrange
    server.start();
    tunnelConnection.onConnected?.call();
    connectRequestStatus = ConnectRequestStatus.invalidOtp;

    // action
    injectTunnelConnectedMessage();

    // assert
    expect(tunnelConnection.sentClientMessages.length, 1);

    final message = tunnelConnection.sentClientMessages[0];
    expect((message as ChannelClosedMessage).reason!.code,
        ChannelCloseCode.authenticationError.index);
  });

  test('channel-closed should be sent if the display code is invalid',
      () async {
    // arrange
    server.start();
    tunnelConnection.onConnected?.call();
    connectRequestStatus = ConnectRequestStatus.invalidDisplayCode;

    // action
    injectTunnelConnectedMessage();

    // assert
    expect(tunnelConnection.sentClientMessages.length, 1);

    final message = tunnelConnection.sentClientMessages[0];
    expect((message as ChannelClosedMessage).reason!.code,
        ChannelCloseCode.invalidDisplayCode.index);
  });

  test('notifies when tunnel connection is successfully established', () async {
    // arrange
    server.start();

    // action
    tunnelConnection.onConnected?.call();

    // assert
    expect(onTunnelConnectedCalled, isTrue);
  });

  test('notifies when tunnel connection enters connecting state', () async {
    // arrange
    server.start();
    tunnelConnection.onConnecting?.call();

    // action

    // assert
    expect(onTunnelConnectingCalled, isTrue);
  });

  test('Reconnect when tunnel connection is disconnected', () async {
    // arrange
    server.start();
    tunnelConnection.onConnected?.call();

    // action
    tunnelConnection.onDisconnected?.call();

    // assert
    expect(createTunnelConnectionCalledCount, greaterThan(1));
  });
}
