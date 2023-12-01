import 'package:display_channel/src/util/fake_tunnel_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:display_channel/display_channel.dart';
import 'dart:io';
import 'dart:async';

class ExpectValueCompleter<T> {
  final completer = Completer();
  final T _expectValue;

  ExpectValueCompleter(this._expectValue);
  void updateValue(T value) {
    if (_expectValue == value) {
      completer.complete();
    }
  }
}

void main() {
  late FakeTunnelService tunnelService;
  late HttpWebSocketServer httpServer;

  late DisplayDirectServer directServer;
  late DisplayTunnelServer tunnelServer;

  late DisplayChannelClient client;

  final clientConnected = Completer();
  final serverChannelOpened = Completer();
  final numberOfMessagesReached = ExpectValueCompleter(4);

  // store messages received by the client
  final clientMessages = <ChannelMessage>[];

  // store messages received by the server
  final serverMessages = <ChannelMessage>[];

  void handleNewChannel(Channel channel) {
    serverChannelOpened.complete();

    channel.onChannelMessage = (message) {
      serverMessages.add(message);
      numberOfMessagesReached.updateValue(serverMessages.length);
    };
  }

  Future<void> setupServer() async {
    // create a fake tunnel service
    tunnelService = FakeTunnelService();

    httpServer = HttpWebSocketServer((WebSocket ws, HttpRequest req) {
      tunnelService.onWsConnection(ws, req);
    });
    await httpServer.start(0);

    // server
    final tunnelServiceUrl = 'ws://127.0.0.1:${httpServer.port}';

    // create a channel server
    directServer = DisplayDirectServer(
      (Channel channel) => handleNewChannel(channel),
      (String token) => true,
    );

    tunnelServer = DisplayTunnelServer(
      (String url, headers) => WebSocketClientConnection(url, headers),
      (Channel channel) => handleNewChannel(channel),
      (String token) => true,
    );

    // start the tunnel server
    tunnelServer.start("1234", tunnelServiceUrl);

    // start the direct server
    await directServer.start(0);
  }

  void setupClient() {
    client.onChannelMessage = (message) {
      clientMessages.add(message);
    };

    client.onStateChange = (state) {
      if (state == ChannelState.connected) {
        clientConnected.complete();
      }
    };
  }

  void openDirectChannel() {
    const clientId = 'abc';
    final serverUrl = 'ws://127.0.0.1:${directServer.port}';
    const token = 'token1';

    client = DisplayChannelClient(
      clientId,
      Uri.parse(serverUrl),
      (url, headers) => WebSocketClientConnection(url, headers),
    );

    client.openDirectChannel(
      token,
    );

    client.onChannelMessage = (message) {
      clientMessages.add(message);
    };

    client.onStateChange = (state) {
      if (state == ChannelState.connected) {
        clientConnected.complete();
      }
    };

    setupClient();
  }

  void openTunnelChannel() {
    const clientId = 'abc';
    final serverUrl = 'ws://127.0.0.1:${httpServer.port}';
    const token = 'token1';
    const displayCode = '1111111';

    client = DisplayChannelClient(
      clientId,
      Uri.parse(serverUrl),
      (url, headers) => WebSocketClientConnection(url, headers),
    );

    client.openTunnelChannel(
      displayCode,
      token,
    );

    setupClient();
  }

  void sendFakeMessages(Channel channel) {
    final messages = [
      DisplayStatusMessage(),
      JoinDisplayMessage('1234'),
      StartPresentMessage('11111'),
      PresentAcceptedMessage('11111'),
    ];

    for (var m in messages) {
      channel.send(m);
    }
  }

  setUp(() {
    return Future(() async {
      await setupServer();
    });
  });

  test('deliver messages directly to the server', () async {
    // arrange
    openDirectChannel();

    // action
    await clientConnected.future;
    await serverChannelOpened.future;

    sendFakeMessages(client);

    // assert
    await numberOfMessagesReached.completer.future;

    expect(serverMessages[0].messageType, ChannelMessageType.displayStatus);
    expect(serverMessages[1].messageType, ChannelMessageType.joinDisplay);
    expect(serverMessages[2].messageType, ChannelMessageType.startPresent);
    expect(serverMessages[3].messageType, ChannelMessageType.presentAccepted);
  });

  test('deliver messages via the tunnel', () async {
    // arrange
    openTunnelChannel();

    // action
    await clientConnected.future;
    await serverChannelOpened.future;

    sendFakeMessages(client);

    // assert
    await numberOfMessagesReached.completer.future;

    expect(serverMessages[0].messageType, ChannelMessageType.displayStatus);
    expect(serverMessages[1].messageType, ChannelMessageType.joinDisplay);
    expect(serverMessages[2].messageType, ChannelMessageType.startPresent);
    expect(serverMessages[3].messageType, ChannelMessageType.presentAccepted);
  });
}
