import 'package:args/args.dart';
import 'package:display_channel/src/websocket_client_connection_config.dart';
import 'package:uuid/uuid.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/util/log.dart';
import 'client.dart';

main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'tunnelUrl',
      defaultsTo: 'wss://ap-northeast-1.gateway.dev.airsync.net',
    )
    ..addOption(
      'otp',
      defaultsTo: '1111',
    )
    ..addOption(
      'code',
      mandatory: true,
    );

  ArgResults argResults = parser.parse(arguments);

  final clientId = const Uuid().v4();
  final otp = argResults['otp'];
  final encodedDisplayCode = argResults['code'];
  final tunnelServiceUrl = argResults['tunnelUrl'];

  createConnectionTunnel(url) => WebSocketClientConnection(
      url,
      WebSocketClientConnectionConfig(
        retry: const RetryConfig(
          maxRetryDelay: Duration(seconds: 1),
          maxRetryAttempts: 4,
        ),
        logger: (url, message) => log().info('$url $message'),
        allowSelfSignedCertificates: false,
      ));

  createConnectionDirect(url) => WebSocketClientConnection(
        url,
        WebSocketClientConnectionConfig(
          retry: const RetryConfig(
            maxRetryDelay: Duration(seconds: 1),
            maxRetryAttempts: 4,
          ),
          logger: (url, message) => log().info('$url $message'),
          allowSelfSignedCertificates: true,
        ),
      );

  Future<String> fetchTunnelUrl(instanceIndex) async => tunnelServiceUrl;

  final displayCode = decodeDisplayCode(encodedDisplayCode);

  final client = DisplayChannelConnector(
    clientId: clientId,
    otp: otp,
    displayCode: displayCode,
    encodedDisplayCode: encodedDisplayCode,
    createConnectionTunnel: createConnectionTunnel,
    createConnectionDirect: createConnectionDirect,
    fetchTunnelUrl: fetchTunnelUrl,
    onOpened: (channel, bool isDirectChannel) {
      Client(clientId, channel);
    },
    onOpenError: (error) {
      log().info('Failed to open the channel $error');
    },
  );

  log().info('opening the channel');

  client.open(directPort: 5100);
}
