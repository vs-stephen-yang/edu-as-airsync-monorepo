import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/server/multi_connection_channel.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

class FakeConnection extends Connection {
  final sentMessages = <ChannelMessage>[];

  bool isCloseCalled = false;

  @override
  void send(Map<String, dynamic> message) {
    final parsedMessage = ChannelMessage.parse(message);
    sentMessages.add(parsedMessage!);
  }

  @override
  void close() {}
}

void main() {
  late MultiConnectionChannel channel;
  late FakeConnection connection1;
  late FakeConnection connection2;
  late List<ChannelState> stateChanges;
  late List<ChannelMessage> receivedMessages;

  setUp(() {
    channel = MultiConnectionChannel(
      '0001',
      'token1',
      heartbeatInterval: const Duration(seconds: 100),
      heartbeatTimeout: const Duration(seconds: 100),
      reconnectTimeout: const Duration(seconds: 200),
    );

    stateChanges = <ChannelState>[];
    receivedMessages = <ChannelMessage>[];

    channel.onStateChange = (state) => stateChanges.add(state);
    channel.onChannelMessage = (message) => receivedMessages.add(message);

    connection1 = FakeConnection();
    connection2 = FakeConnection();
  });

  test('channel should send channel-connected for each new connection', () {
    // arrange

    // action
    channel.addConnection(connection1);

    channel.addConnection(connection2);

    // assert
    expect(connection1.sentMessages.length, 1);
    expect(connection1.sentMessages[0], isA<ChannelConnectedMessage>());

    expect(connection2.sentMessages.length, 1);
    expect(connection2.sentMessages[0], isA<ChannelConnectedMessage>());
  });

  test('channel should send heartbeat periodically', () {
    // arrange

    fakeAsync((async) {
      channel.addConnection(connection1);

      // action
      async.elapse(const Duration(seconds: 200));

      // assert
      expect(connection1.sentMessages.length, 3);
      // two hearbeats
      expect(connection1.sentMessages[1], isA<HeartbeatMessage>());
      expect(connection1.sentMessages[2], isA<HeartbeatMessage>());
    });
  });

  test('channel starts with the connected state', () {
    // arrange

    // action

    // assert
    expect(channel.state, ChannelState.connected);
  });

  test('channel should close if the client cannot reconnect within timeout',
      () {
    // arrange
    channel.addConnection(connection1);

    fakeAsync((async) {
      // action
      connection1.onClosed?.call(connection1);

      async.elapse(const Duration(seconds: 200));

      // assert
      expect(stateChanges.last, ChannelState.closed);
    });
  });

  test('channel should send message to each connection', () {
    // arrange
    channel.addConnection(connection1);
    channel.addConnection(connection2);

    // action
    channel.send(AllowPresentMessage());

    // assert
    expect(connection1.sentMessages.length, 2);
    expect(connection1.sentMessages[1], isA<AllowPresentMessage>());

    expect(connection2.sentMessages.length, 2);
    expect(connection2.sentMessages[1], isA<AllowPresentMessage>());
  });

  test('channel should receive messages from a connection', () {
    // arrange
    channel.addConnection(connection1);

    // action
    final messages = buildMessages([0, 3, 2, 1], true);

    for (var message in messages) {
      connection1.onMessage?.call(
        connection1,
        message.toJson(),
      );
    }

    // assert
    expect(receivedMessages.length, 4);
  });

  test('client should receive channel-close when channel is closed', () {
    // arrange
    channel.addConnection(connection1);

    // action
    channel.close(null);

    // assert
    expect(connection1.sentMessages.length, 2);
    expect(connection1.sentMessages[1], isA<ChannelClosedMessage>());
  });
}
