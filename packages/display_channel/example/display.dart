import 'package:display_channel/display_channel.dart';

class Client {
  final Channel _channel;

  Client(this._channel) {
    final message = DisplayStatusMessage();
    _channel.send(message);

    _channel.onChannelMessage = (message) => _onMessages(message);
  }

  void _onMessages(ChannelMessage message) {
    print('Received ${message.messageType}');

    switch (message.messageType) {
      case ChannelMessageType.joinDisplay:
        onJoinDisplay(message as JoinDisplayMessage);
        break;
      case ChannelMessageType.startPresent:
        onStartPresent(message as StartPresentMessage);
        break;

      case ChannelMessageType.presentSignal:
        onPresentSignal(message as PresentSignalMessage);
      default:
        break;
    }
  }

  void onJoinDisplay(JoinDisplayMessage msg) {}

  void onStartPresent(StartPresentMessage msg) {
    final message = PresentAcceptedMessage(msg.sessionId);
    _channel.send(message);
  }

  void onPresentSignal(PresentSignalMessage msg) {
    switch (msg.signalType) {
      case SignalMessageType.offer:
        // response sdp answer
        final message =
            PresentSignalMessage(msg.sessionId, SignalMessageType.answer);
        _channel.send(message);
        break;
      case SignalMessageType.candidate:
        final message =
            PresentSignalMessage(msg.sessionId, SignalMessageType.candidate);
        _channel.send(message);
        break;
      default:
        break;
    }
  }
}

class MockServer {
  late DisplayDirectServer _directServer;
  late DisplayTunnelServer _tunnelServer;

  final _clients = <Client>[];

  MockServer() {
    // create a direct server
    _directServer = DisplayDirectServer(
      (Channel channel) => _onNewChannel(channel),
      (String token) => true,
    );

    // create a tunnel server
    _tunnelServer = DisplayTunnelServer(
      (String url) => WebSocketClientConnection(url),
      (Channel channel) => _onNewChannel(channel),
      (String token) => true,
    );

    _tunnelServer.onTunnelConnected = () {
      print('Tunnel connects');
    };
    _tunnelServer.onTunnelConnecting = () {
      print('Tunnel is connecting');
    };
  }

  // start the server
  Future<void> start(
    String instanceId,
    String tunnelServiceUrl,
    int localPort,
  ) async {
    // start the tunnel server
    print('Connecting to $tunnelServiceUrl for tunnel channels');
    _tunnelServer.start(instanceId, tunnelServiceUrl);

    // start the direct server
    await _directServer.start(localPort);
    print('Listened on port ${_directServer.port} for direct channels');
  }

  void _onNewChannel(Channel channel) {
    print('A new channel has been created on the server-side');

    // create a client object to handle this channel
    final client = Client(channel);

    _clients.add(client);
  }
}

main() async {
  const tunnelServiceUrl = 'wss://ap-northeast-1.gateway.dev.airsync.net';
  const localDirectPort = 5100;
  const instanceId = '0002';

  final server = MockServer();

  await server.start(
    instanceId,
    tunnelServiceUrl,
    localDirectPort,
  );
}
