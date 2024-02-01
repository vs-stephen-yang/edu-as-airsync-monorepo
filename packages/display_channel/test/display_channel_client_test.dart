import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

class FakeClientConnection extends ClientConnection {
  bool isOpenCalled = false;
  bool isCloseCalled = false;

  final sentMessages = <ChannelMessage?>[];
  String? url;

  FakeClientConnection();

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
    sentMessages.add(ChannelMessage.parse(message));
  }
}

void main() {
  late List<ChannelMessage> outgoingMessages1;
  late List<ChannelMessage> incomingMessages1;

  late List<ChannelMessage> receivedMessages;
  late List<ChannelState> stateChanges;

  late FakeClientConnection connection;
  late DisplayChannelClient client;

  void injectIncomingMessages(List<ChannelMessage> messages) {
    for (var message in messages) {
      connection.onMessage?.call(message.toJson());
    }
  }

  void injectIncomingHearbeatMessage(int ack) {
    connection.onMessage?.call(
      HeartbeatMessage(ack).toJson(),
    );
  }

  setUp(() {
    incomingMessages1 = buildMessages([0, 3, 2, 1], true);

    receivedMessages = <ChannelMessage>[];
    stateChanges = <ChannelState>[];

    connection = FakeClientConnection();

    client = DisplayChannelClient(
      '1000',
      Uri.parse('ws://abc.com'),
      (url) {
        connection.url = url;
        return connection;
      },
    );

    client.onChannelMessage = (message) => receivedMessages.add(message);
    client.onStateChange = (state) => stateChanges.add(state);
  });

  test('connection should be opened with a correct URL', () {
    // arrange

    // action
    client.openDirectChannel('1313', displayCode: 'DEF');

    // assert
    expect(connection.isOpenCalled, true);

    expect(
      connection.url,
      'ws://abc.com?clientId=1000&displayCode=DEF&token=1313',
    );
  });

  test('state should be connected after the connection is established', () {
    // arrange

    // action
    client.openDirectChannel('1234', displayCode: 'ABC');
    connection.onConnected?.call();

    // assert
    expect(stateChanges.length, 1);
    expect(stateChanges[0], ChannelState.connected);
  });

  test('client-connected should be sent when the connection is connected', () {
    // arrange

    // action
    client.openDirectChannel('1234', displayCode: 'ABC');
    connection.onConnected?.call();

    // assert
    expect(connection.sentMessages.length, 1);

    expect((connection.sentMessages[0] as ClientConnectedMessage).ack, 0);
  });

  test(
      'client-connected should be sent with correct ack after the connection is reconnected',
      () {
    // arrange

    // action
    client.openDirectChannel('1234', displayCode: 'ABC');
    connection.onConnected?.call();

    injectIncomingMessages(incomingMessages1);

    // simulate reconnection
    connection.onConnecting?.call();
    connection.onConnected?.call();

    // assert
    expect(connection.sentMessages.length, 2);

    expect((connection.sentMessages[1] as ClientConnectedMessage).ack, 4);
  });
}
