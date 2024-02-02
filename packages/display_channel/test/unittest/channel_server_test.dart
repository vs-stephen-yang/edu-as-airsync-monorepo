import 'package:display_channel/src/channel.dart';
import 'package:display_channel/src/channel_server.dart';
import 'package:display_channel/src/server/connection.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeChannelServer extends ChannelServer {
  FakeChannelServer(
    super.onNewChannel,
    super.verifyConnectRequest,
  );

  @override
  void stop() {}
}

class FakeConnection extends Connection {
  @override
  void close() {}

  @override
  void send(Map<String, dynamic> message) {}
}

void main() {
  late FakeChannelServer server;
  late List<Channel> channels;
  ConnectRequestStatus fakeConnectRequestStatus = ConnectRequestStatus.success;

  setUp(() {
    channels = <Channel>[];

    server = FakeChannelServer(
      (channel) {
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

  test('closeAllChannels() should close all the channels', () async {
    // arrange
    server.handleNewConnection('1000', FakeConnection());
    server.handleNewConnection('1001', FakeConnection());

    // action
    server.closeAllChannels();

    // assert
    expect(channels[0].state, ChannelState.closed);
    expect(channels[1].state, ChannelState.closed);
  });
}
