import 'dart:async';

import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

class FakeClientConnection extends ClientConnection {
  bool isOpenCalled = false;
  bool isCloseCalled = false;

  final sentMessages = <ChannelMessage?>[];
  final urls = <String>[];

  Completer? _createCompleter;

  FakeClientConnection();

  void create(String url) {
    urls.add(url);

    _createCompleter?.complete();
  }

  Future waitCreate(int count) async {
    while (urls.length < count) {
      _createCompleter = Completer();

      await _createCompleter!.future;
    }
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
    sentMessages.add(ChannelMessage.parse(message));
  }
}

void main() {
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

  void injectChannelConnected(String token, int ack) {
    connection.onMessage?.call(
      ChannelConnectedMessage(1000, 1000, token, ack).toJson(),
    );
  }

  void injectHeartbeat(int ack) {
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
        connection.create(url);
        return connection;
      },
    );

    client.onChannelMessage = (message) => receivedMessages.add(message);
    client.onStateChange = (state) => stateChanges.add(state);
  });

  test('The direct connection should be opened with a correct URL', () {
    // arrange

    // action
    client.openDirectChannel('1313', displayCode: 'DEF');

    // assert
    expect(connection.isOpenCalled, true);

    expect(
      connection.urls[0],
      'ws://abc.com?clientId=1000&displayCode=DEF&token=1313',
    );
  });

  test('The tunnel connection should be opened with a correct URL', () {
    // arrange

    // action
    client.openTunnelChannel('100000', '1313', displayCode: 'DEF');

    // assert
    expect(connection.isOpenCalled, true);

    expect(
      connection.urls.first,
      'ws://abc.com?clientId=1000&displayCode=DEF&token=1313&role=client&instanceIndex=100000',
    );
  });

  test('state should be connected after the connection is established', () {
    // arrange
    client.openDirectChannel('token', displayCode: 'ABC');

    // action
    connection.onConnected?.call();

    // assert
    expect(stateChanges.length, 1);
    expect(stateChanges.first, ChannelState.connected);
  });

  test('client-connected should be sent when the connection is connected', () {
    // arrange
    client.openDirectChannel('token', displayCode: 'ABC');

    // action
    connection.onConnected?.call();

    // assert
    expect(connection.sentMessages.length, 1);

    expect((connection.sentMessages[0] as ClientConnectedMessage).ack, 0);
  });

  test('client-connected should be sent after the connection is reconnected',
      () {
    // arrange
    client.openDirectChannel('token', displayCode: 'ABC');
    connection.onConnected?.call();

    injectChannelConnected('token2', 0);
    injectIncomingMessages(incomingMessages1);

    // action
    // simulate reconnection
    connection.onDisconnected?.call();
    connection.onConnected?.call();

    // assert
    expect(connection.sentMessages.length, 2);

    expect((connection.sentMessages[1] as ClientConnectedMessage).ack, 4);
  });

  test('shoud connect using the reconnection token during reconnection',
      () async {
    // arrange
    client.openDirectChannel('token', displayCode: 'ABC');
    connection.onConnected?.call();

    injectChannelConnected('token2', 0);

    // action
    // simulate disconnection
    connection.onDisconnected?.call();

    await connection.waitCreate(2);

    // assert
    expect(connection.urls.length, 2);

    expect(
      connection.urls[0],
      'ws://abc.com?clientId=1000&displayCode=ABC&token=token',
    );

    expect(
      connection.urls[1],
      'ws://abc.com?clientId=1000&displayCode=ABC&token=token2',
    );
  });

  test('A heartbeat should be sent when a heartbeat is received', () async {
    // arrange
    client.openDirectChannel('token', displayCode: 'ABC');
    connection.onConnected?.call();

    injectChannelConnected('token2', 0);

    // action
    injectHeartbeat(0);

    // assert
    expect(connection.sentMessages.length, 2);

    expect((connection.sentMessages[1] as HeartbeatMessage).ack, 0);
  });
}
