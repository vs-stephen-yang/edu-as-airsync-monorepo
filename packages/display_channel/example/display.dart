import 'dart:io';

import 'package:args/args.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/util/log.dart';

class Client {
  final Channel _channel;

  Client(this._channel) {
    final message = DisplayStatusMessage();
    _channel.send(message);

    _channel.onChannelMessage = (message) => _onMessages(message);
    _channel.onStateChange = (state) {
      log().info('Channel state has changed to $state');
    };
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
      (Channel channel) => _onNewChannel(channel),
      _verifyConnectRequest,
    );

    // create a tunnel server
    _tunnelServer = DisplayTunnelServer(
      (String url) => WebSocketClientConnection(
        url,
        logger: (String url, String message) {
          log().info('$url $message');
        },
      ),
      (Channel channel) => _onNewChannel(channel),
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
    String tunnelServiceUrl,
    int localPort,
    SecurityContext securityContext,
  ) async {
    // start the tunnel server
    log().info('Connecting to $tunnelServiceUrl for tunnel channels');
    _tunnelServer.start(instanceId, tunnelServiceUrl);

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
      'tunnelUrl',
      defaultsTo: 'wss://ap-northeast-1.gateway.dev.airsync.net',
    );

  ArgResults argResults = parser.parse(arguments);

  final tunnelServiceUrl = argResults['tunnelUrl'];
  final host = argResults['host'];
  const localDirectPort = 5100;
  const instanceId = '0001';
  const instanceIndex = 100043;

  log().info('Current directory: ${Directory.current.path}');

  final securityContext = await _loadSecurityContext(
    'example/assets/cert.pem',
    'example/assets/key.pem',
  );

  final server = MockServer();

  await server.start(
      instanceId, tunnelServiceUrl, localDirectPort, securityContext);

  final encodedDisplayCode = encodeDisplayCode(
    DisplayCode(host, instanceIndex),
  );
  final encodedDisplayCode1 = encodeDisplayCode(
    DisplayCode(host, 0),
  );

  log().info('Display Code: $encodedDisplayCode $encodedDisplayCode1');
}
