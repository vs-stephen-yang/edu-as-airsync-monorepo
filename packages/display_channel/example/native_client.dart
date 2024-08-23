import 'package:args/args.dart';
import 'package:uuid/uuid.dart';
import 'package:display_channel/display_channel.dart';
import 'package:display_channel/src/util/log.dart';
import 'package:display_channel/src/util/api_util.dart';
import 'client.dart';

main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'otp',
      defaultsTo: '1111',
    )
    ..addOption(
      'apiOrigin',
      defaultsTo: 'https://api2.gateway.dev.airsync.net',
    )
    ..addOption(
      'code',
      mandatory: true,
    );

  ArgResults argResults = parser.parse(arguments);

  final clientId = const Uuid().v4();
  final otp = argResults['otp'];
  final encodedDisplayCode = argResults['code'];
  final apiOrigin = argResults['apiOrigin'];

  final localIpAddresses = await fetchIPv4Addresses();

  createConnectionTunnel(url, bool isReconnect) => WebSocketClientConnection(
      url,
      WebSocketClientConnectionConfig(
        retry: const RetryConfig(
          maxRetryDelay: Duration(seconds: 1),
          maxRetryAttempts: 4,
        ),
        logger: (url, message) => log().info('$url $message'),
        allowSelfSignedCertificates: false,
      ));

  createConnectionDirect(url, bool isReconnect) => WebSocketClientConnection(
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

  Future<String> fetchTunnelUrl(
    int instanceIndex,
    int instanceGroupId,
  ) async {
    log().info('Fetching the instance Info');
    final tunnelUrl = await fetchInstanceInfo(
      apiOrigin,
      instanceIndex,
      instanceGroupId,
    );
    log().info('Fetched the instance Info. $tunnelUrl');
    return tunnelUrl;
  }

  log().info('Display Code: $encodedDisplayCode');
  final displayCode = decodeDisplayCode(encodedDisplayCode);

  log().info('Instance Group Id: ${displayCode.instanceGroupId}');
  log().info('Instance Index: ${displayCode.instanceIndex}');

  final client = DisplayChannelConnector(
    clientId: clientId,
    otp: otp,
    displayCode: displayCode,
    localIpAddresses: localIpAddresses,
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

  log().info('Opening the channel');

  client.open();
}
