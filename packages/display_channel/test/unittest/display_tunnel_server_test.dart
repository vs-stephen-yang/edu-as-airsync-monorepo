import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message.dart';
import 'package:flutter_test/flutter_test.dart';

import 'contains_map_matcher.dart';

class FakeClientConnection extends ClientConnection {
  FakeClientConnection();
  bool isCloseCalled = false;

  Uri? url;

  @override
  void open() {}

  @override
  Future<void> close() {
    isCloseCalled = true;
    return Future<void>.value();
  }

  @override
  void send(Map<String, dynamic> message) {}
}

void main() {
  late DisplayTunnelServer server;
  late FakeClientConnection connection;
  Channel? channel;
  late bool onTunnelConnectedCalled;
  late bool onTunnelConnectingCalled;

  injectTunnelConnectedMessage(String connectionId, String token) {
    final message = TunnelClientConnected(
      connectionId,
      '100',
      token,
      'DEF',
    );

    connection.onMessage?.call(message.toJson());
  }

  setUp(() {
    connection = FakeClientConnection();

    server = DisplayTunnelServer(
      (String url, bool isReconnect) {
        connection.url = Uri.parse(url);
        return connection;
      },
      (Channel c, queryParameters) {
        channel = c;
      },
      (ConnectionRequest connectionRequest) => ConnectRequestStatus.success,
    );

    onTunnelConnectedCalled = false;
    onTunnelConnectingCalled = false;

    server.onTunnelConnected = () {
      onTunnelConnectedCalled = true;
    };

    server.onTunnelConnecting = () {
      onTunnelConnectingCalled = true;
    };
  });

  test('start should create a connection with correct URI', () async {
    // arrange

    // action
    server.start('1000', 1, Uri.parse('wss://example.com/dev'));

    // assert
    final actual = connection.url;
    expect(actual?.path, '/dev');

    expect(
      actual?.queryParameters,
      ContainsMapMatcher({
        'role': 'server',
        'instanceId': '1000',
      }),
    );
  });

  test('stop should close the connection', () async {
    // arrange
    server.start('1000', 1, Uri.parse('wss://example.com/dev'));

    // action
    server.stop();

    // assert
    expect(connection.isCloseCalled, true);
  });

  test('a new channel should be created when connected is received', () async {
    // arrange
    server.start('1000', 1, Uri.parse('wss://example.com/dev'));

    // action
    injectTunnelConnectedMessage('1000', 'token');

    // assert
    expect(channel, isNotNull);
    expect(channel!.state, ChannelState.connected);
  });

  test('should be notified when the connected is connected', () async {
    // arrange
    server.start('1000', 1, Uri.parse('wss://example.com/dev'));

    // action
    connection.onConnected?.call();

    // assert
    expect(onTunnelConnectedCalled, true);
  });

  test('should be notified when the connected is connecting', () async {
    // arrange
    server.start('1000', 1, Uri.parse('wss://example.com/dev'));

    // action
    connection.onConnecting?.call();

    // assert
    expect(onTunnelConnectingCalled, true);
  });
}
