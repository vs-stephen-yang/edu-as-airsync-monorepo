import 'package:flutter/material.dart';
import 'package:display_channel/display_channel.dart';
import 'package:uuid/uuid.dart';
import 'package:display_channel/src/util/log.dart';

import 'client.dart';

void main() {
  const tunnelServiceUrl = 'wss://ap-northeast-1.gateway.dev.airsync.net';
  const token = '1111';
  const instanceIndex = 1;
  const instanceGroupId = 1;
  const displayCode = 'ABA';

  final uri = Uri.parse(tunnelServiceUrl);

  final clientId = const Uuid().v4();

  // Create a client channel
  final channel = DisplayChannelClient(
    clientId,
    uri,
    (url, bool isReconnect) => WebSocketClientConnection(
      url,
      WebSocketClientConnectionConfig(
        retry: const RetryConfig(
          maxRetryDelay: Duration(seconds: 1),
          maxRetryAttempts: 4,
        ),
        logger: (url, message) => log().info('$url $message'),
      ),
    ),
  );

  Client(clientId, channel);

  channel.openTunnelChannel(
    instanceIndex,
    instanceGroupId,
    token,
    displayCode: displayCode,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Flutter App with Button',
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Connect'),
          ),
        ),
      ),
    );
  }
}
