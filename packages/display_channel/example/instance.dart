import 'dart:io';

import 'package:args/args.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/util/api_util.dart';
import 'package:display_channel/src/util/log.dart';
import 'package:display_channel/src/util/stage_util.dart';

class Client {
  final Channel _channel;

  Client(this._channel) {
    final message = DisplayStatusMessage();
    _channel.send(message);

    _channel.onChannelMessage = (message) => _onMessages(message);
    _channel.stateController.stream.listen((ChannelState state) {
      log().info('Channel state has changed to $state');
      if (state == ChannelState.closed) {
        log().info(
            'Close reason: ${_channel.closeReason?.code} ${_channel.closeReason?.text}');
      }
    });
  }

  void _onMessages(ChannelMessage message) {
    log().info('Received ${message.messageType}');

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

Future<SecurityContext> _loadSecurityContext(
  String certPemPath,
  String keyPemPath,
) async {
  final certificateChain = await File(certPemPath).readAsBytes();
  final privateKey = await File(keyPemPath).readAsString();

  // Create a security context
  return SecurityContext()
    ..useCertificateChainBytes(certificateChain)
    ..usePrivateKeyBytes(privateKey.codeUnits);
}

class MockServer {
  late DisplayDirectServer _directServer;
  late DisplayTunnelServer _tunnelServer;

  final _clients = <Client>[];

  ConnectRequestStatus _verifyConnectRequest(
    ConnectionRequest connectionRequest,
  ) {
    log().info(
        'Connect request ${connectionRequest.displayCode} ${connectionRequest.token}');

    return (connectionRequest.token == '1111')
        ? ConnectRequestStatus.success
        : ConnectRequestStatus.invalidOtp;
  }

  MockServer() {
    // create a direct server
    _directServer = DisplayDirectServer(
      (Channel channel, queryParameters) => _onNewChannel(channel),
      _verifyConnectRequest,
    );

    // create a tunnel server
    _tunnelServer = DisplayTunnelServer(
      (String url, bool isReconnect) => WebSocketClientConnection(
        url,
        WebSocketClientConnectionConfig(
          logger: (String url, String message) {
            log().info('$url $message');
          },
        ),
      ),
      (Channel channel, queryParameters) => _onNewChannel(channel),
      _verifyConnectRequest,
    );

    _tunnelServer.onTunnelConnected = () {
      log().info('Tunnel connects');
    };
    _tunnelServer.onTunnelConnecting = () {
      log().info('Tunnel is connecting');
    };
  }

  // start the server
  Future<void> start(
    String instanceId,
    int instanceGroupId,
    Uri uri,
    int localPort,
    SecurityContext securityContext,
  ) async {
    // start the tunnel server
    log().info('Connecting to ${uri.toString()} for tunnel channels');
    _tunnelServer.start(
      instanceId,
      instanceGroupId,
      uri,
    );

    // start the direct server
    await _directServer.start(
      localPort,
      securityContext: securityContext,
    );
    log().info('Listened on port ${_directServer.port} for direct channels');
  }

  void _onNewChannel(Channel channel) {
    log().info('A new channel has been created on the server-side');

    // create a client object to handle this channel
    final client = Client(channel);

    _clients.add(client);
  }
}

main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'host',
      mandatory: true,
    )
    ..addOption(
      'instanceId',
      defaultsTo: 'test-f834455f-9569-4313-85d9-2b72a67e0b8b',
    )
    ..addOption(
      'stage',
      defaultsTo: 'dev',
    );

  ArgResults argResults = parser.parse(arguments);

  final host = argResults['host'];
  const localPort = 5100;
  final stage = parseStage(argResults['stage']);
  final instanceId = argResults['instanceId'];

  final apiOrigin = getStageApiUrl(stage);

  log().info('Stage: ${stage.name}');
  log().info('API origin: $apiOrigin');
  log().info('Host: $host');
  log().info('Port: $localPort');
  log().info('Current directory: ${Directory.current.path}');

  final instanceGroupId = getInstanceGroupIdFromIp(host);

  // Register the instance
  log().info('Registering the instance');
  final instanceInfo = await registerInstance(
    apiOrigin,
    instanceId,
    instanceGroupId,
  );

  final encodedDisplayCode = encodeDisplayCode(
    DisplayCode(
      instanceGroupId: instanceGroupId,
      instanceIndex: instanceInfo.instanceIndex,
    ),
  );
  final encodedDisplayCode1 = encodeDisplayCode(
    DisplayCode(
      instanceGroupId: instanceGroupId,
    ),
  );

  log().info('Instance Id: $instanceId');
  log().info('Instance Group Id: $instanceGroupId');
  log().info('Instance Index: ${instanceInfo.instanceIndex}');
  log().info('Display Code: $encodedDisplayCode $encodedDisplayCode1');

  final securityContext = await _loadSecurityContext(
    'example/assets/cert.pem',
    'example/assets/key.pem',
  );

  final server = MockServer();

  await server.start(
    instanceId,
    instanceGroupId,
    Uri.parse(instanceInfo.tunnelApiUrl),
    localPort,
    securityContext,
  );
}
