import 'dart:async';
import 'package:display_channel/src/websocket_client_connection_config.dart';
import 'package:logging/logging.dart';
import 'package:args/args.dart';
import 'package:uuid/uuid.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/util/log.dart';

class TestRunner {
  final DisplayChannelClient _client;

  Timer? _sendTimer;

  int _clientSent = 0;
  int _clientReceived = 0;
  int _serverSent = 0;
  int _serverReceived = 0;

  TestRunner(this._client) {
    Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        log().info(
          '$_clientSent,$_clientReceived,$_serverSent,$_serverReceived',
        );
      },
    );

    _client.onStateChange = (state) {
      switch (state) {
        case ChannelState.connecting:
          log().info('The client is connecting');
          break;
        case ChannelState.connected:
          log().info('The client has connected');
          if (_sendTimer != null) {
            return;
          }
          _sendTimer = Timer.periodic(
            const Duration(milliseconds: 1000),
            (timer) {
              final message = DisplayStatusMessage();
              message.name = _clientSent.toString();

              _client.send(message);
              log().info('C S ${message.name}');
              _clientSent++;
            },
          );
          break;
        case ChannelState.closed:
          _sendTimer?.cancel();
          log().warning(
            'The client has closed. Reason: ${_client.closeReason?.code}',
          );
          break;
        default:
          break;
      }
    };

    _client.onChannelMessage = (message) {
      switch (message.messageType) {
        case ChannelMessageType.displayStatus:
          log().info('C R ${(message as DisplayStatusMessage).name}');
          _clientReceived++;
          break;
        default:
          break;
      }
    };
  }

  _onNewChannel(Channel channel) {
    channel.onStateChange = (state) {
      switch (state) {
        case ChannelState.connecting:
          log().warning(
            'The channel is connecting',
          );
        case ChannelState.closed:
          log().warning(
            'The channel has closed. Reason: ${_client.closeReason?.code}',
          );
          break;
        default:
          break;
      }
    };

    channel.onChannelMessage = (message) {
      switch (message.messageType) {
        case ChannelMessageType.displayStatus:
          log().info('S R ${(message as DisplayStatusMessage).name}');
          _serverReceived++;

          // echo the message to the client
          final echoMessage = DisplayStatusMessage();
          echoMessage.name = message.name;

          channel.send(echoMessage);
          log().info('S S ${echoMessage.name}');
          _serverSent++;
          break;
        default:
          break;
      }
    };
  }
}

main(List<String> arguments) async {
  Logger.root.level = Level.ALL;

  final parser = ArgParser()
    ..addOption(
      'tunnelUrl',
      defaultsTo: 'wss://ap-northeast-1.gateway.dev.airsync.net',
    )
    ..addOption(
      'instanceId',
      defaultsTo: '0001',
    )
    ..addOption(
      'instanceIndex',
      defaultsTo: '100043',
    );

  ArgResults argResults = parser.parse(arguments);

  final clientId = const Uuid().v4();
  final instanceIndex = argResults['instanceIndex'];
  final instanceId = argResults['instanceId'];
  final tunnelServiceUrl = argResults['tunnelUrl'];

  final tunnelServiceUri = Uri.parse(tunnelServiceUrl);

  // Create a client channel
  final client = DisplayChannelClient(
    clientId,
    tunnelServiceUri,
    (url) => WebSocketClientConnection(
        url,
        WebSocketClientConnectionConfig(
          retry: const RetryConfig(
            maxRetryDelay: Duration(seconds: 1),
            maxRetryAttempts: 4,
          ),
          logger: (url, message) => log().fine('c $message'),
        )),
  );

  final runner = TestRunner(client);

  final server = DisplayTunnelServer(
    (String url) => WebSocketClientConnection(
      url,
      WebSocketClientConnectionConfig(
        logger: (String url, String message) {
          log().fine('s $message');
        },
      ),
    ),
    (Channel channel) => runner._onNewChannel(channel),
    (connectionRequest) => ConnectRequestStatus.success,
  );

  server.onTunnelConnected = () {
    log().info('Tunnel connects');
  };
  server.onTunnelConnecting = () {
    log().info('Tunnel is connecting');
  };

  server.start(instanceId, tunnelServiceUrl);

  log().info('Opening the channel to ${tunnelServiceUri.toString()}');

  await Future.delayed(const Duration(seconds: 2));

  client.openTunnelChannel(
    instanceIndex,
    'token',
    displayCode: 'ABCDE',
  );
}
