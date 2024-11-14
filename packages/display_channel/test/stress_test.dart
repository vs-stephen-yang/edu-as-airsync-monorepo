import 'dart:async';

import 'package:args/args.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/util/log.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

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

    _client.stateStream.listen((ChannelState state) {
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
    });

    _client.messageStream.listen((message) {
      switch (message.messageType) {
        case ChannelMessageType.displayStatus:
          log().info('C R ${(message as DisplayStatusMessage).name}');
          _clientReceived++;
          break;
        default:
          break;
      }
    });
  }

  _onNewChannel(Channel channel) {
    channel.stateStream.listen((ChannelState state) {
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
    });

    channel.messageStream.listen((message) {
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
    });
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
      defaultsTo: 'integration-test-001',
    )
    ..addOption(
      'instanceGroupId',
      defaultsTo: '16777214',
    )
    ..addOption(
      'instanceIndex',
      defaultsTo: '2',
    );

  ArgResults argResults = parser.parse(arguments);

  final clientId = const Uuid().v4();
  final instanceIndex = argResults['instanceIndex'];
  final instanceId = argResults['instanceId'];
  final instanceGroupId = int.parse(argResults['instanceGroupId']);
  final tunnelServiceUrl = argResults['tunnelUrl'];

  final tunnelServiceUri = Uri.parse(tunnelServiceUrl);

  // Create a client channel
  final client = DisplayChannelClient(
    clientId,
    tunnelServiceUri,
    (url, bool isReconnect) => WebSocketClientConnection(
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
    (String url, bool isReconnect) => WebSocketClientConnection(
      url,
      WebSocketClientConnectionConfig(
        logger: (String url, String message) {
          log().fine('s $message');
        },
      ),
    ),
    (Channel channel, _) => runner._onNewChannel(channel),
    (connectionRequest) => ConnectRequestStatus.success,
  );

  server.onTunnelConnected = () {
    log().info('Tunnel connects');
  };
  server.onTunnelConnecting = () {
    log().info('Tunnel is connecting');
  };

  server.start(instanceId, instanceGroupId, tunnelServiceUrl);

  log().info('Opening the channel to ${tunnelServiceUri.toString()}');

  await Future.delayed(const Duration(seconds: 2));

  client.openTunnelChannel(
    instanceIndex,
    instanceGroupId,
    'token',
    displayCode: 'ABCDE',
  );
}
