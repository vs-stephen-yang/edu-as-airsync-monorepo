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

  @override
  Map<String, String>? get queryParameters => {};
}

void main() {
  late MultiConnectionChannel channel;
  late FakeConnection connection1;
  late FakeConnection connection2;
  late List<ChannelState> stateChanges;
  late List<ChannelMessage> receivedMessages;

  ExpectValueCompleter? numberOfReceivedMessagesReached;

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

    channel.stateStream.listen((ChannelState state) {
      stateChanges.add(state);
    });
    channel.messageStream.listen((message) {
      receivedMessages.add(message);

      numberOfReceivedMessagesReached?.updateValue(
        receivedMessages.length,
      );
    });

    connection1 = FakeConnection();
    connection2 = FakeConnection();
  });

  test('channel should send heartbeat periodically', () {
    // arrange

    fakeAsync((async) {
      channel.addConnection(connection1);

      // action
      async.elapse(const Duration(seconds: 200));

      // assert

      final messages = lastN(connection1.sentMessages, 2);

      // two hearbeats
      expect(messages[0], isA<HeartbeatMessage>());
      expect(messages[1], isA<HeartbeatMessage>());
    });
  });

  test('channel starts with the connected state', () {
    // arrange

    // action

    // assert
    expect(channel.state, ChannelState.connected);
  });

  test('The state should change to connecting after disconnected', () {
    // arrange
    channel.addConnection(connection1);

    // action
    connection1.onClosed?.call(connection1);

    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      expect(stateChanges.last, ChannelState.connecting);
    });
  });

  test('The state should change to connected after reconnected', () {
    // arrange
    channel.addConnection(connection1);
    connection1.onClosed?.call(connection1);

    // action
    channel.addConnection(connection2);
    connection2.onMessage?.call(
      connection1,
      ClientConnectedMessage(0).toJson(),
    );

    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      expect(stateChanges.last, ChannelState.connected);
    });
  });

  test(
      'Channel should close when client fails to reconnect within the timeout period',
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

  test('Channel should broadcasts messages to all active connections', () {
    // arrange
    channel.addConnection(connection1);
    channel.addConnection(connection2);

    // action
    channel.send(AllowPresentMessage());

    // assert
    expect(connection1.sentMessages.last, isA<AllowPresentMessage>());

    expect(connection2.sentMessages.last, isA<AllowPresentMessage>());
  });

  test('Channel correctly receives messages from a connection', () async {
    // arrange
    numberOfReceivedMessagesReached = ExpectValueCompleter(4);

    channel.addConnection(connection1);

    // action
    final messages = buildMessages([0, 3, 2, 1], true);

    // inject the messages
    for (var message in messages) {
      connection1.onMessage?.call(
        connection1,
        message.toJson(),
      );
    }

    // assert
    await numberOfReceivedMessagesReached?.completer.future;
    expect(receivedMessages.length, 4);
  });

  test('channel-close should be sent when the channel is closed', () {
    // arrange
    channel.addConnection(connection1);

    // action
    channel.close(null);

    // assert
    expect(connection1.sentMessages.last, isA<ChannelClosedMessage>());
  });

  test(
      'Channel should respond with channel-connected after receiving client-connected',
      () {
    // arrange
    channel.addConnection(connection1);

    // action
    connection1.onMessage?.call(
      connection1,
      ClientConnectedMessage(0).toJson(),
    );

    // assert
    expect(connection1.sentMessages.first, isA<ChannelConnectedMessage>());
  });
}
