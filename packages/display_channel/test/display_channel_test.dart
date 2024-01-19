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
  late HttpServer httpServer;

  late DisplayDirectServer directServer;
  late DisplayTunnelServer tunnelServer;

  late DisplayChannelClient client;
  late Channel serverChannel;

  // Completer
  late Completer clientConnected;
  late Completer serverChannelOpened;
  late ExpectValueCompleter numberOfMessagesReached;
  late Completer clientClosed;
  late Completer serverChannelClosed;
  late Completer tunnelConnected;

  // store messages received by the client
  late List<ChannelMessage> clientMessages;

  // store messages received by the server
  late List<ChannelMessage> serverMessages;

  void handleNewChannel(Channel channel) {
    serverChannelOpened.complete();
    serverChannel = channel;

    channel.onChannelMessage = (message) {
      serverMessages.add(message);
      numberOfMessagesReached.updateValue(serverMessages.length);
    };

    channel.onStateChange = (state) {
      if (state == ChannelState.closed) {
        serverChannelClosed.complete();
      }
    };
  }

  Future<void> setupServer() async {
    // create a fake tunnel service
    tunnelService = FakeTunnelService('1111111');

    const httpPort = 0;
    httpServer = await HttpServer.bind(
      InternetAddress.anyIPv4,
      httpPort,
    );

    httpServer.listen((request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        tunnelService.onHttpRequest(request);
      }
    });

    // server
    final tunnelServiceUrl = 'ws://127.0.0.1:${httpServer.port}';

    // create a channel server
    directServer = DisplayDirectServer(
      (Channel channel) => handleNewChannel(channel),
      (String token) => token == 'token1',
    );

    tunnelServer = DisplayTunnelServer(
      (String url) => WebSocketClientConnection(url),
      (Channel channel) => handleNewChannel(channel),
      (String token) => token == 'token1',
    );

    tunnelServer.onTunnelConnected = () {
      tunnelConnected.complete();
    };
    // start the tunnel server
    tunnelServer.start("1234", tunnelServiceUrl);

    // start the direct server
    await directServer.start(0);

    // wait until the tunnel is established
    await tunnelConnected.future;
  }

  void setupClient() {
    client.onChannelMessage = (message) {
      clientMessages.add(message);
    };

    client.onStateChange = (state) {
      if (state == ChannelState.connected) {
        clientConnected.complete();
      } else if (state == ChannelState.closed) {
        clientClosed.complete();
      }
    };
  }

  void openDirectChannel({int? port, String token = 'token1'}) {
    const clientId = 'abc';
    final serverUrl = 'ws://127.0.0.1:${port ?? directServer.port}';

    client = DisplayChannelClient(
      clientId,
      Uri.parse(serverUrl),
      (url) => WebSocketClientConnection(url, maxRetryAttempts: 1),
    );

    setupClient();

    client.openDirectChannel(
      token,
    );
  }

  void openTunnelChannel({
    int? port,
    String token = 'token1',
    String displayCode = '1111111',
  }) {
    const clientId = 'abc';
    final serverUrl = 'ws://127.0.0.1:${port ?? httpServer.port}';

    client = DisplayChannelClient(
      clientId,
      Uri.parse(serverUrl),
      (url) => WebSocketClientConnection(url, maxRetryAttempts: 1),
    );

    setupClient();

    client.openTunnelChannel(
      displayCode,
      token,
    );
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
      clientConnected = Completer();
      serverChannelOpened = Completer();
      numberOfMessagesReached = ExpectValueCompleter(4);
      clientClosed = Completer();
      serverChannelClosed = Completer();
      tunnelConnected = Completer();

      clientMessages = <ChannelMessage>[];

      serverMessages = <ChannelMessage>[];

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

  test('The server-side should be notified when the client closes the channel.',
      () async {
    // arrange
    openDirectChannel();

    await clientConnected.future;
    await serverChannelOpened.future;

    // action
    client.close(ChannelCloseReason(ChannelCloseCode.close));

    // assert
    await serverChannelClosed.future;
    expect(serverChannel.closeReason!.code, ChannelCloseCode.remoteClose);
  });

  test('The client-side should be notified when the server closes the channel.',
      () async {
    // arrange
    openDirectChannel();

    await clientConnected.future;
    await serverChannelOpened.future;

    // action
    serverChannel.close(ChannelCloseReason(ChannelCloseCode.close));

    // assert
    await clientClosed.future;
    expect(client.closeReason!.code, ChannelCloseCode.remoteClose);
  });

  test('The channel should be closed with authenticationError if otp is wrong',
      () async {
    // arrange
    openDirectChannel(token: 'wrong');
    await clientConnected.future;

    // action

    // assert
    await clientClosed.future;
    expect(client.closeReason!.code, ChannelCloseCode.authenticationError);
  });

  test(
      'The channel should be closed with transportClose if the direct server does not exist',
      () async {
    // arrange
    openDirectChannel(port: 1);

    // action

    // assert
    await clientClosed.future;
    expect(client.closeReason!.code, ChannelCloseCode.transportClose);
  });

  test(
      'The channel should be closed with channelNotFound if the display code does not exist',
      () async {
    // arrange
    openTunnelChannel(displayCode: '000');

    // action

    // assert
    await clientClosed.future;
    expect(client.closeReason!.code, ChannelCloseCode.channelNotFound);
  });
}
