import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/channel_store.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:display_channel/src/server/connection_request.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeConnection extends Connection {
  @override
  void close() {}

  @override
  void send(Map<String, dynamic> message) {}

  @override
  Map<String, String>? get queryParameters => {};
}

void main() {
  late ChannelStore server;
  late List<Channel> channels;
  ConnectRequestStatus fakeConnectRequestStatus = ConnectRequestStatus.success;

  setUp(() {
    channels = <Channel>[];

    server = ChannelStore(
      (channel, queryParameters) {
        channels.add(channel);
      },
      (connectRequest) => fakeConnectRequestStatus,
    );
  });

  test('handleNewConnection() should create a new channel', () async {
    // arrange
    final connection = FakeConnection();

    // action
    server.handleNewConnection('1000', connection);

    // assert
    expect(channels.length, 1);
  });

  test('Multiple connections from the a client should create one channel',
      () async {
    // arrange
    final connection1 = FakeConnection();
    final connection2 = FakeConnection();

    // action
    server.handleNewConnection('1000', connection1);
    server.handleNewConnection('1000', connection2);

    // assert
    expect(channels.length, 1);
  });

  test('Channel should be removed after it closes', () async {
    // arrange
    final connection = FakeConnection();
    server.handleNewConnection('1000', connection);

    // action
    await channels.first.close(null);

    // assert
    expect(server.channelCount, 0);
  });

  test(
      'A reconnection request should be rejected if the channel has been closed.',
      () async {
    // arrange
    final connection = FakeConnection();
    server.handleNewConnection('1000', connection);
    await channels.first.close(null);

    final reconnectionRequest = ConnectionRequest(
      '1000',
      'a' * 36, // dummy string simulating UUID v4 format length
      '000111',
      '192.168.1.2',
    );

    // action
    final status = server.verifyConnectionRequest(reconnectionRequest);

    // assert
    expect(status, ConnectRequestStatus.channelClosed);
  });
}
