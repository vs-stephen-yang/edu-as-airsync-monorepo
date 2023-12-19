import 'package:display_channel/display_channel.dart';
import 'package:args/args.dart';
import 'package:uuid/uuid.dart';

class MockClient {
  final DisplayChannelClient _channel;

  final String _clientId;
  final _sessionId = const Uuid().v4();

  MockClient(this._clientId, this._channel) {
    _channel.onChannelMessage = (message) {
      print('Received ${message.messageType}');

      switch (message.messageType) {
        case ChannelMessageType.displayStatus:
          _onDisplayStatus(message as DisplayStatusMessage);
          break;
        default:
          break;
      }
    };
  }

  void _onDisplayStatus(DisplayStatusMessage message) {
    _joinDisplay();
    _startPresent();

    _presentSignal(SignalMessageType.offer);

    for (int i = 0; i < 5; i++) {
      _presentSignal(SignalMessageType.candidate);
    }
  }

  void _joinDisplay() {
    final msg = JoinDisplayMessage(_clientId);
    _channel.send(msg);
  }

  void _startPresent() {
    final msg = StartPresentMessage(_sessionId);
    _channel.send(msg);
  }

  void _presentSignal(SignalMessageType signalType) {
    final msg = PresentSignalMessage(_sessionId, signalType);
    _channel.send(msg);
  }
}

main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'mode',
      defaultsTo: 'direct',
      allowed: ['direct', 'tunnel'],
    );

  ArgResults argResults = parser.parse(arguments);

  final clientId = const Uuid().v4();
  const token = 'token1';
  const displayCode = '1683441648';
  const tunnelServiceUrl = 'wss://ap-northeast-1.gateway.dev.airsync.net';

  bool direct = argResults['mode'] == 'direct';

  // Server URL
  final uri = direct
      ? Uri(
          scheme: 'ws',
          host: "127.0.0.1",
          port: 5100,
        )
      : Uri.parse(tunnelServiceUrl);

  // Create a client channel
  final channel = DisplayChannelClient(
    clientId,
    uri,
    (url, headers) => WebSocketClientConnection(url, headers),
  );

  channel.onStateChange = (ChannelState state) {
    switch (state) {
      case ChannelState.connecting:
        print('The client is connecting to the display');
        break;
      case ChannelState.connected:
        print('The client has connected to the display');
        break;
      case ChannelState.disconnected:
        print('The client has disconnected to the display');
        break;
      case ChannelState.closed:
        print('The client has closed');
        break;
      default:
        break;
    }
    ;
  };

  MockClient(clientId, channel);

  print('opening the channel to ${uri.toString()}');

  if (direct) {
    channel.openDirectChannel(token);
  } else {
    channel.openTunnelChannel(displayCode, token);
  }
}
