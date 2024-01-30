import 'package:args/args.dart';
import 'package:uuid/uuid.dart';
import 'package:display_channel/display_channel.dart';

import 'client.dart';

main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'mode',
      defaultsTo: 'direct',
      allowed: ['direct', 'tunnel'],
    )
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
      defaultsTo: 'ABA',
    )
    ..addOption(
      'instanceIndex',
      defaultsTo: '100043',
    );

  ArgResults argResults = parser.parse(arguments);

  final clientId = const Uuid().v4();
  final token = argResults['otp'];
  final instanceIndex = argResults['instanceIndex'];
  final displayCode = argResults['code'];
  final tunnelServiceUrl = argResults['tunnelUrl'];

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
    (url) => WebSocketClientConnection(
      url,
      maxRetryDelay: const Duration(seconds: 1),
      maxRetryAttempts: 4,
      logger: (url, message) => print('$url $message'),
    ),
  );

  Client(clientId, channel);

  print('opening the channel to ${uri.toString()}');

  if (direct) {
    channel.openDirectChannel(
      token,
      displayCode: displayCode,
    );
  } else {
    channel.openTunnelChannel(
      instanceIndex,
      token,
      displayCode: displayCode,
    );
  }
}
