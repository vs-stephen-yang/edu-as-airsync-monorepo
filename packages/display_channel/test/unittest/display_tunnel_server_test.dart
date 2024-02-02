import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:display_channel/src/server/tunnel/tunnel_message.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeClientConnection extends ClientConnection {
  FakeClientConnection();

  @override
  void open() {}

  @override
  Future<void> close() {
    return Future<void>.value();
  }

  @override
  void send(Map<String, dynamic> message) {}
}

void main() {
  late DisplayTunnelServer server;
  late FakeClientConnection connection;
  Channel? channel;

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
      (String url) => connection,
      (Channel c) {
        channel = c;
        channel!.onStateChange = (state) {};
      },
      (ConnectionRequest connectionRequest) => ConnectRequestStatus.success,
    );
  });

  test('stop should work', () async {
    // arrange
    server.start('1000', 'wss://example.com/dev');

    // action
    server.stop();

    // assert
  });

  test('a new channel should be created when connected is received', () async {
    // arrange
    server.start('1000', 'wss://example.com/dev');

    // action
    injectTunnelConnectedMessage('1000', 'token');

    // assert
    expect(channel, isNotNull);
    expect(channel!.state, ChannelState.connected);
  });
}
