import 'dart:async';

import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/client_connection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'contains_map_matcher.dart';
import 'utils.dart';

class FakeClientConnection extends ClientConnection {
  bool isOpenCalled = false;
  bool isCloseCalled = false;

  final sentMessages = <ChannelMessage?>[];
  final urls = <Uri>[];

  Completer? _createCompleter;

  FakeClientConnection();

  void create(String url) {
    urls.add(Uri.parse(url));

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

  ExpectValueCompleter? numberOfReceivedMessagesReached;
  ExpectValueCompleter? numberOfStateChangesReached;

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

  void injectChannelClosed(ChannelCloseCode closeCode) {
    connection.onMessage?.call(
      ChannelClosedMessage(Reason(
        closeCode.index,
      )).toJson(),
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
      (url, bool isReconnect) {
        connection.create(url);
        return connection;
      },
    );

    client.messageStream.listen((message) {
      receivedMessages.add(message);

      numberOfReceivedMessagesReached?.updateValue(
        receivedMessages.length,
      );
    });

    client.stateStream.listen((ChannelState state) {
      stateChanges.add(state);

      numberOfStateChangesReached?.updateValue(
        stateChanges.length,
      );
    });
  });

  tearDown(() {
    numberOfStateChangesReached = null;
    numberOfReceivedMessagesReached = null;
  });

  test('The direct connection should be opened with a correct URL', () {
    // arrange

    // action
    client.openDirectChannel(token: '1313', displayCode: 'DEF');

    // assert
    expect(connection.isOpenCalled, true);

    final actual = connection.urls.first;

    expect(actual.host, 'abc.com');
    expect(
      actual.queryParameters,
      ContainsMapMatcher({
        'clientId': '1000',
        'displayCode': 'DEF',
        'token': '1313',
      }),
    );
  });

  test('The tunnel connection should be opened with a correct URL', () {
    // arrange

    // action
    client.openTunnelChannel(100000, 1, '1313', displayCode: 'DEF');

    // assert
    expect(connection.isOpenCalled, true);

    final actual = connection.urls.first;

    expect(actual.host, 'abc.com');

    expect(
      actual.queryParameters,
      ContainsMapMatcher({
        'clientId': '1000',
        'displayCode': 'DEF',
        'token': '1313',
      }),
    );
  });

  test(
      'The state should not switch to connected after the connection is established',
      () {
    // arrange
    client.openDirectChannel(token: 'token', displayCode: 'ABC');

    // action
    connection.onConnected?.call();

    // assert
    expect(stateChanges, isEmpty);
  });

  test('The state should switch to connected after receiving channel-connected',
      () async {
    // arrange
    numberOfStateChangesReached = ExpectValueCompleter(1);

    client.openDirectChannel(token: 'token', displayCode: 'ABC');

    // action
    connection.onConnected?.call();
    injectChannelConnected('token2', 0);

    // assert
    await numberOfStateChangesReached?.completer.future;
    expect(stateChanges.first, ChannelState.connected);
  });

  test('client-connected should be sent when the connection is connected', () {
    // arrange
    client.openDirectChannel(token: 'token', displayCode: 'ABC');

    // action
    connection.onConnected?.call();

    // assert
    final message = connection.sentMessages.first;

    expect(message, isA<ClientConnectedMessage>());
    expect((message as ClientConnectedMessage).ack, equals(0));
  });

  test('client-connected should be sent after the connection is reconnected',
      () {
    // arrange
    client.openDirectChannel(token: 'token', displayCode: 'ABC');
    connection.onConnected?.call();

    injectChannelConnected('token2', 0);
    injectIncomingMessages(incomingMessages1);

    // action
    // simulate reconnection
    connection.onDisconnected?.call();
    connection.onConnected?.call();

    // assert
    expect(connection.sentMessages, hasLength(2));

    final message = connection.sentMessages.last;

    expect(message, isA<ClientConnectedMessage>());
    expect((message as ClientConnectedMessage).ack, equals(4));
  });

  test('The token should be the reconnection token when reconnecting',
      () async {
    // arrange
    client.openDirectChannel(token: 'token', displayCode: 'ABC');
    connection.onConnected?.call();

    injectChannelConnected('token2', 0);

    // action
    // simulate disconnection
    connection.onDisconnected?.call();

    await connection.waitCreate(2);

    // assert
    expect(connection.urls, hasLength(2));

    expect(
      connection.urls.last.queryParameters,
      ContainsMapMatcher({
        'token': 'token2',
      }),
    );
  });

  test('A heartbeat should be sent when a heartbeat is received', () async {
    // arrange
    client.openDirectChannel(token: 'token', displayCode: 'ABC');
    connection.onConnected?.call();

    injectChannelConnected('token2', 0);

    // action
    injectHeartbeat(0);

    // assert
    expect(connection.sentMessages, hasLength(2));

    final message = connection.sentMessages.last;

    expect(message, isA<HeartbeatMessage>());
    expect((message as HeartbeatMessage).ack, equals(0));
  });

  test('Correctly handles channel-closed with authenticationRequired reason',
      () async {
    // arrange
    numberOfStateChangesReached = ExpectValueCompleter(1);

    client.openDirectChannel(displayCode: 'ABC');
    connection.onConnected?.call();

    injectChannelClosed(ChannelCloseCode.authenticationRequired);

    // assert
    await numberOfStateChangesReached?.completer.future;

    expect(stateChanges.first, ChannelState.closed);

    expect(
      client.closeReason!.code.index,
      ChannelCloseCode.authenticationRequired.index,
    );
  });

  test('Handles the message', () async {
    // arrange
    numberOfReceivedMessagesReached = ExpectValueCompleter(4);

    client.openDirectChannel(displayCode: 'ABC');
    connection.onConnected?.call();
    injectChannelConnected('token', 0);

    // action
    injectIncomingMessages(incomingMessages1);

    // assert
    await numberOfReceivedMessagesReached?.completer.future;
    expect(receivedMessages, hasLength(4));
  });

  test('Handles the message received before the channel-connected is received',
      () async {
    // arrange
    numberOfReceivedMessagesReached = ExpectValueCompleter(4);

    client.openDirectChannel(displayCode: 'ABC');
    connection.onConnected?.call();

    // action

    // Messages are received before channel-connected
    injectIncomingMessages(incomingMessages1);
    injectChannelConnected('token', 0);

    // assert
    await numberOfReceivedMessagesReached?.completer.future;
    expect(receivedMessages, hasLength(4));
  });
}
